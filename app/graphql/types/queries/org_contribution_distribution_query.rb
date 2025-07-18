# frozen_string_literal: true

module Types
  module Queries
    class OrgContributionDistributionQuery < BaseOverviewQuery

      type [Types::Meta::ContributorTopOverviewType], null: false

      description 'Get organization contributors distribution'

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

        total_count = contributors_list.length
        grouped_data = contributors_list.group_by { _1['ecological_type'] }
        grouped_data.map do |group, grouped_contributors|
          build_org_distribution_data(group, grouped_data[group], total_count, scope: 'contribution')
        end
      end
    end
  end
end
