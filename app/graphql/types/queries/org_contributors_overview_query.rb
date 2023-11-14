# frozen_string_literal: true

module Types
  module Queries
    class OrgContributorsOverviewQuery < BaseQuery

      type [Types::Meta::ContributorTopOverviewType], null: false

      description 'Get organization contributors overview'

      argument :label, String, required: true, description: 'repo or project label'
      argument :level, String, required: false, description: 'repo or comunity', default_value: 'repo'
      argument :page, Integer, required: false, description: 'page number'
      argument :per, Integer, required: false, description: 'page size'
      argument :filter_opts, [Input::FilterOptionInput], required: false, description: 'filter options'
      argument :begin_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'begin date'
      argument :end_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'end date'

      def resolve(label: nil, level: 'repo', page: 1, per: 9, filter_opts: [], begin_date: nil, end_date: nil)

        label = normalize_label(label)

        validate_by_label!(context[:current_user], label)

        begin_date, end_date, interval = extract_date(begin_date, end_date)

        indexer, repo_urls =
                 select_idx_repos_by_lablel_and_level(label, level, GiteeContributorEnrich, GithubContributorEnrich)

        contributors_list =
          indexer
            .fetch_contributors_list(repo_urls, begin_date, end_date)
            .then { indexer.filter_contributors(_1, filter_opts) }

        grouped_data = contributors_list.group_by { _1['organization'] }
        transformed_data = grouped_data.transform_values { |v| v.map { |h| h['contribution'] }.reduce(0, :+) }
        sorted_data = transformed_data.sort_by { |_, v| -v }
        total_count = transformed_data.map { |_k, v| v }.reduce(0, :+)

        sorted_data
          .first(10)
          .map { |group, _| build_distribution_data(group, grouped_data[group], total_count) }
      end

      def build_distribution_data(group, grouped_contributors, total_count)
        sub_total = grouped_contributors.map { _1['contribution'] }.reduce(0, :+)
        sorted_contributors = grouped_contributors.sort_by { -_1['contribution'] }
        top_contributors = sorted_contributors.first(10)
        top_contributor_distribution =
          top_contributors.map do |contributor|
          {
            sub_count: contributor['contribution'],
            sub_ratio: total_count == 0 ? 0 : (contributor['contribution'].to_f / total_count).round(4),
            sub_name: contributor['contributor'],
            total_count: total_count
          }
        end

        other_contributors_count =
          sub_total - top_contributor_distribution.sum { |h| h[:sub_count] }

        if other_contributors_count > 0
          top_contributor_distribution << {
            sub_count: other_contributors_count,
            sub_ratio: total_count == 0 ? 0 : (other_contributors_count.to_f / total_count).round(4),
            sub_name: 'other',
            total_count: total_count
          }
        end

        {
          overview_name: self.class.name,
          sub_type_name: group,
          sub_type_percentage: sub_total == 0 ? 0 : (sub_total.to_f / total_count).round(4),
          top_contributor_distribution: top_contributor_distribution
        }
      end
    end
  end
end
