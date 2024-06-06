# frozen_string_literal: true

module Types
  module Queries
    class CommitsDetailPageQuery < BaseQuery

      type Types::Meta::CommitDetailPageType, null: false
      description 'Get commits detail list of a repo or community'
      argument :label, String, required: true, description: 'repo or project label'
      argument :level, String, required: false, description: 'repo or community', default_value: 'repo'
      argument :branch, String, required: false, description: 'commit branch', default_value: 'master'
      argument :page, Integer, required: false, description: 'page number'
      argument :per, Integer, required: false, description: 'per page number'
      argument :filter_opts, [Input::FilterOptionInput], required: false, description: 'filter options'
      argument :sort_opts, [Input::SortOptionInput], required: false, description: 'sort options'
      argument :begin_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'begin date'
      argument :end_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'end date'

      def resolve(label: nil, level: 'repo', branch: 'master', page: 1, per: 9, begin_date: nil, end_date: nil,
                  filter_opts: [], sort_opts: [])
        label = ShortenedLabel.normalize_label(label)

        login_required!(context[:current_user])
        validate_by_label!(context[:current_user], label)

        begin_date, end_date, interval = extract_date(begin_date, end_date)

        indexer, repo_urls =
                 select_idx_repos_by_lablel_and_level(label, level, GiteeGitEnrich, GithubGitEnrich)

        pull_indexer, repo_urls =
                  select_idx_repos_by_lablel_and_level(label, level, GiteePullEnrich, GithubPullEnrich)

        resp = indexer.fetch_commit_page_by_repo_urls(repo_urls, begin_date, end_date, branch, per: per, page: page,
                                                      filter_opts: filter_opts, sort_opts: sort_opts,
                                                      label: label, level: level)

        count = indexer.commit_count_by_repo_urls(repo_urls, begin_date, end_date, branch, filter_opts: filter_opts)
        hits = resp&.[]('hits')&.[]('hits') || []

        domain_list = hits.map { |data| data.dig('_source', 'author_domain') }.to_set.to_a
        domain_map = Organization.map_by_domain_list(domain_list)

        commit_hash_list = hits.map { |data| data.dig('_source', 'hash') }.to_set.to_a
        pull_indexer_resp = pull_indexer.list_by_repo_urls(repo_urls, Time.parse("1970-01-01"), end_date,
                                                           commit_hash_list: commit_hash_list)
        commit_hash_map = (pull_indexer_resp&.[]('hits')&.[]('hits') || []).each_with_object({}) do |hash, map|
          hash['_source']['commits_data'].each do |key|
            map[key] = hash['_source']
          end
        end

        commit_feedback_list = CommitFeedback.fetch_commit_feedback_list(repo_urls, commit_hash_list,
                                                                         value_field: "commit_hash.keyword", state: "approved")
        commit_feedback_map = commit_feedback_list.each_with_object({}) do |hash, map|
          map[hash['commit_hash']] = hash
        end


        items =
          hits.map do |data|
          skeleton = Hash[Types::Meta::CommitDetailType.fields.keys.map(&:underscore).zip([])]
          skeleton = skeleton.merge(data['_source']).symbolize_keys
          skeleton[:repo_name] = skeleton[:repo_name].gsub(".git", "")
          skeleton[:commit_hash] = data['_source']['hash']
          skeleton[:org_name] = domain_map.dig(data['_source']['author_domain'], "org_name")
          skeleton[:pr_url] = commit_hash_map.dig(data['_source']['hash'], "url")
          skeleton[:merged_at] = commit_hash_map.dig(data['_source']['hash'], "merged_at")
          if commit_feedback_map.include?(skeleton[:commit_hash])
            skeleton[:lines_added] = commit_feedback_map.dig(skeleton[:commit_hash], 'new_lines_added')
            skeleton[:lines_removed] = commit_feedback_map.dig(skeleton[:commit_hash], 'new_lines_removed')
            skeleton[:lines_changed] = commit_feedback_map.dig(skeleton[:commit_hash], 'new_lines_changed')
          end
          skeleton
        end

        { count: count, total_page: (count.to_f/per).ceil, page: page, items: items }
      end
    end
  end
end
