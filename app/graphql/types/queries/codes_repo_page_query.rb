# frozen_string_literal: true

module Types
  module Queries
    class CodesRepoPageQuery < BaseQuery

      type Types::Meta::CodeRepoPageType, null: false
      description 'Get code list of a repo or community'
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
        code_repo_map = {}
        resp = indexer.fetch_commit_agg_list_by_repo_urls(repo_urls, start_time, end_date, branch, agg_field: 'tag', per: 10000,
                                              filter_opts: filter_opts, sort_opts: sort_opts, label: label, level: level)

        buckets = resp&.[]('aggregations')&.[]('group_by_name')&.[]('buckets') || []
        current_buckets =
          (buckets.in_groups_of(per)&.[]([page.to_i - 1, 0].max) || [])
            .compact
            .map { OpenStruct.new(_1) }

        current_buckets.map do |data|
          code_repo_map[data['key'].gsub(".git", "")] = { 'lines_total' => data['lines_total']['value'] }
        end
        current_page_repo_urls = code_repo_map.keys

        pull_indexer_resp = pull_indexer.list_by_repo_urls(current_page_repo_urls, begin_date, end_date)
        commit_hash_map = (pull_indexer_resp&.[]('hits')&.[]('hits') || []).each_with_object({}) do |hash, map|
          hash['_source']['commits_data'].each do |key|
            map[key] = hash['_source']
          end
        end

        resp = indexer.fetch_commit_agg_list_by_repo_urls(current_page_repo_urls, start_time, end_date, branch,
                                                          commit_hash_list: commit_hash_map.keys, agg_field: 'tag',
                                                          per: 10000, label: label, level: level)
        buckets = resp&.[]('aggregations')&.[]('group_by_name')&.[]('buckets') || []
        commit_map = buckets.each_with_object({}) do |data, hash|
          hash[data['key'].gsub(".git", "")] = {
            'lines_total' => data['lines_total']['value']
          }
        end

        repo_sig_list = SubjectSig.fetch_subject_sig_list_by_repo_urls(label, level, current_page_repo_urls, filter_opts: filter_opts)
        repo_sig_map = repo_sig_list.each_with_object({}) { |hash, map| map[hash[:label]] = hash }


        repo_extension_resp = RepoExtension.list_by_repo_urls(current_page_repo_urls, filter_opts: filter_opts)
        repo_extension_map = (repo_extension_resp&.[]('hits')&.[]('hits') || []).each_with_object({}) { |hash, map|
          map[hash['_source']['repo_name']] = hash['_source'] }

        items =
          current_page_repo_urls.map do |data|
            skeleton = Hash[Types::Meta::CodeRepoType.fields.keys.map(&:underscore).zip([])].symbolize_keys
            skeleton[:repo_attribute_type] = repo_extension_map.dig(data, 'repo_attribute_type')
            skeleton[:repo_name] = data
            skeleton[:sig_name] = repo_sig_map.dig(data, :sig_name)
            skeleton[:manager] = repo_extension_map.dig(data, 'manager')
            skeleton[:lines_total] = code_repo_map.dig(data, 'lines_total') || 0
            skeleton[:lines] = code_repo_map.dig(data, 'lines_total') || 0
            skeleton[:lines_chang] = commit_map.dig(data, 'lines_total') || 0
            skeleton
          end

        current_page =
          (items.in_groups_of(per)&.[]([page.to_i - 1, 0].max) || [])
            .compact
            .map { OpenStruct.new(_1) }

        count = repo_urls.length

        { count: count, total_page: (count.to_f/per).ceil, page: page, items: current_page }
      end
    end
  end
end
