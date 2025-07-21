# frozen_string_literal: true

module Types
  module Queries
    class OrgContributorsOverviewQuery < BaseOverviewQuery

      TOP_COUNT = 10

      type [Types::Meta::ContributorTopOverviewType], null: false

      description 'Get organization contributors overview'

      argument :label, String, required: true, description: 'repo or project label'
      argument :level, String, required: false, description: 'repo or comunity', default_value: 'repo'
      argument :filter_opts, [Input::FilterOptionInput], required: false, description: 'filter options'
      argument :begin_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'begin date'
      argument :end_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'end date'

      def resolve(label: nil, level: 'repo', filter_opts: [], begin_date: nil, end_date: nil)

        label = ShortenedLabel.normalize_label(label)

        login_required!(context[:current_user])

        validate_by_label!(context[:current_user], label)

        begin_date, end_date, interval = extract_date(begin_date, end_date)

        validate_date!(context[:current_user], label, level, begin_date, end_date)

        indexer, repo_urls =
                 select_idx_repos_by_lablel_and_level(label, level, GiteeContributorEnrich, GithubContributorEnrich, GitcodeContributorEnrich)

        contributors_list =
          indexer
            .fetch_contributors_list(repo_urls, begin_date, end_date, label: label, level: level)
            .then { indexer.filter_contributors(_1, filter_opts) }

        grouped_data = contributors_list.group_by { _1['organization'] }.except(nil)
        transformed_data = grouped_data.transform_values { |v| v.map { |h| h['contribution'] }.reduce(0, :+) }
        sorted_data = transformed_data.sort_by { |_, v| -v }
        total_count = transformed_data.map { |_k, v| v }.reduce(0, :+)

        top_grouped_data =
          sorted_data.first(TOP_COUNT)
            .map { |group, _| build_distribution_data(group, grouped_data[group], total_count) }

        if sorted_data.size > TOP_COUNT
          other_grouped_data = sorted_data.drop(TOP_COUNT).map { |group, _| grouped_data[group] }.reduce(&:+)
        end

        top_grouped_data << build_distribution_data('other', other_grouped_data, total_count) if other_grouped_data

        top_grouped_data
      end
    end
  end
end
