# frozen_string_literal: true

module Types
  module Queries
    class ContributorsDetailListQuery < BaseQuery

      type Types::Meta::ContributorDetailPageType, null: false
      description 'Get contributors detail list of a repo or community'
      argument :label, String, required: true, description: 'repo or project label'
      argument :level, String, required: false, description: 'repo or comunity', default_value: 'repo'
      argument :page, Integer, required: false, description: 'page number'
      argument :per, Integer, required: false, description: 'page size'
      argument :filter_opts, [Input::FilterOptionInput], required: false, description: 'filter options'
      argument :sort_opts, [Input::SortOptionInput], required: false, description: 'sort options'
      argument :begin_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'begin date'
      argument :end_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'end date'

      def resolve(label: nil, level: 'repo', page: 1, per: 9, filter_opts: [], sort_opts: [], begin_date: nil, end_date: nil)
        label = normalize_label(label)

        validate_by_label!(context[:current_user], label)

        begin_date, end_date, interval = extract_date(begin_date, end_date)

        validate_date!(context[:current_user], label, level, begin_date, end_date)

        indexer, repo_urls =
                 select_idx_repos_by_lablel_and_level(label, level, GiteeContributorEnrich, GithubContributorEnrich)
        contributors_list =
          indexer
            .fetch_contributors_list(repo_urls, begin_date, end_date)
            .then { indexer.filter_contributors(_1, filter_opts) }
            .then { indexer.sort_contributors(_1, sort_opts) }

        current_page =
          (contributors_list.in_groups_of(per)&.[]([page.to_i - 1, 0].max) || [])
            .compact
            .map { OpenStruct.new(_1) }

        count = contributors_list.length

        { count: count, total_page: (count.to_f/per).ceil, page: page, items: current_page }
      end
    end
  end
end
