# frozen_string_literal: true

module Types
  module Queries
    class IssuesDetailListQuery < BaseQuery

      type Types::Meta::IssueDetailPageType, null: false
      description 'Get issues detail list of a repo or community'
      argument :label, String, required: true, description: 'repo or project label'
      argument :level, String, required: false, description: 'repo or community', default_value: 'repo'
      argument :page, Integer, required: false, description: 'page number'
      argument :per, Integer, required: false, description: 'per page number'
      argument :filter_opts, [Input::FilterOptionInput], required: false, description: 'filter options'
      argument :sort_opts, [Input::SortOptionInput], required: false, description: 'sort options'
      argument :begin_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'begin date'
      argument :end_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'end date'

      def resolve(label: nil, level: 'repo', page: 1, per: 9, begin_date: nil, end_date: nil, filter_opts: [], sort_opts: [])
        label = normalize_label(label)

        login_required!(context[:current_user])

        validate_by_label!(context[:current_user], label)

        begin_date, end_date, interval = extract_date(begin_date, end_date)

        validate_date!(context[:current_user], label, level, begin_date, end_date)

        indexer, repo_urls =
                 select_idx_repos_by_lablel_and_level(label, level, GiteeIssueEnrich, GithubIssueEnrich)

        filter_opts << OpenStruct.new(type: 'pull_request', values: ['false']) if indexer == GithubIssueEnrich

        resp = indexer.terms_by_repo_urls(repo_urls, begin_date, end_date, per: per, page: page, filter_opts: filter_opts, sort_opts: sort_opts)

        count = indexer.count_by_repo_urls(repo_urls, begin_date, end_date, filter_opts: filter_opts)

        hits = resp&.[]('hits')&.[]('hits') || []
        items =
          hits.map do |data|
          skeleton = Hash[Types::Meta::IssueDetailType.fields.keys.map(&:underscore).zip([])]
          skeleton.merge(data['_source']).symbolize_keys
        end

        { count: count, total_page: (count.to_f/per).ceil, page: page, items: items }
      end
    end
  end
end
