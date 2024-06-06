# frozen_string_literal: true

module Types
  module Queries
    class CodesDetailPageQuery < BaseQuery

      type Types::Meta::CodeDetailPageType, null: false
      description 'Get code detail list of a repo or community'
      argument :label, String, required: true, description: 'repo or project label'
      argument :level, String, required: false, description: 'repo or community', default_value: 'repo'
      argument :branch, String, required: false, description: 'commit branch', default_value: 'master'
      argument :page, Integer, required: false, description: 'page number'
      argument :per, Integer, required: false, description: 'per page number'
      argument :filter_opts, [Input::FilterOptionInput], required: false, description: 'filter options'
      argument :sort_opts, [Input::SortOptionInput], required: false, description: 'sort options'
      argument :begin_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'begin date'
      argument :end_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'end date'

      def resolve(label: nil, level: 'repo', branch: 'master',page: 1, per: 9, begin_date: nil, end_date: nil, filter_opts: [], sort_opts: [])
        label = ShortenedLabel.normalize_label(label)
        login_required!(context[:current_user])
        validate_by_label!(context[:current_user], label)

        begin_date, end_date, interval = extract_date(begin_date, end_date)

        indexer, repo_urls =
                 select_idx_repos_by_lablel_and_level(label, level, GiteeGitEnrich, GithubGitEnrich)

        pull_indexer, repo_urls =
          select_idx_repos_by_lablel_and_level(label, level, GiteePullEnrich, GithubPullEnrich)

        start_time = Time.parse("1970-01-01")
        resp = pull_indexer.list_by_repo_urls(repo_urls, begin_date, end_date, filter_opts: filter_opts, sort_opts: sort_opts)
        hits = resp&.[]('hits')&.[]('hits') || []

        current_repo_urls = hits.map { |hit| hit['_source']['tag'] }.compact.flatten.uniq
        pr_commit_hash_list = hits.map { |hit| hit['_source']['commits_data'] }.compact.flatten.uniq
        commit_resp = indexer.fetch_commit_agg_list_by_repo_urls(current_repo_urls, start_time, end_date, branch,
                                                                 commit_hash_list: pr_commit_hash_list, agg_field: 'hash', per: 10000)
        buckets = commit_resp&.[]('aggregations')&.[]('group_by_name')&.[]('buckets') || []
        commit_map = buckets.each_with_object({}) do |data, hash|
          hash[data['key'].gsub(".git", "")] = {
            'lines_total' => data['lines_total']['value']
          }
        end
        commit_hash_list = commit_map.keys

        items =
          hits.map do |data|
            if (data['_source']['commits_data'] & commit_hash_list).empty?
              next
            end
            data_source = data['_source']
            skeleton = Hash[Types::Meta::CodeDetailType.fields.keys.map(&:underscore).zip([])]
            skeleton = skeleton.merge(data_source).symbolize_keys
            skeleton[:issue_num] = data_source.dig('linked_issues')&.first
            skeleton[:lines_total] = data_source.dig('commits_data').reduce(0) { |acc, x|
              acc + (commit_map.dig(x, 'lines_total') || 0)}
            skeleton[:commit_urls] = data_source.dig('commits_data').map { |element|
              data_source.dig('tag') +'/commit/'+ element }
            skeleton
          end
        items = items.compact.uniq

        current_page =
          (items.in_groups_of(per)&.[]([page.to_i - 1, 0].max) || [])
            .compact
            .map { OpenStruct.new(_1) }

        count = items.length

        { count: count, total_page: (count.to_f/per).ceil, page: page, items: current_page }
      end
    end
  end
end
