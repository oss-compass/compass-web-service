# frozen_string_literal: true

module Types
  module Queries
    class CodesCheckPageQuery < BaseQuery

      type Types::Meta::CodeCheckPageType, null: false
      description 'Get code check detail list of a repo or community'
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

        begin_date, end_date, interval = extract_date(begin_date, end_date)

        pull2_indexer, repo_urls = select_idx_repos_by_lablel_and_level(label, level, Gitee2PullEnrich, Github2PullEnrich)
        pull_indexer, repo_urls = select_idx_repos_by_lablel_and_level(label, level, GiteePullEnrich, GithubPullEnrich)
        git_indexer, repo_urls = select_idx_repos_by_lablel_and_level(label, level, GiteeGitEnrich, GithubGitEnrich)

        user_login_list = pull2_indexer.list_user_login_by_repo_urls(repo_urls, begin_date, end_date,
                                                                     filter_opts: filter_opts, sort_opts: sort_opts)

        current_user_login_list = (user_login_list.in_groups_of(per)&.[]([page.to_i - 1, 0].max) || []).compact
        pull2_resp = pull2_indexer.fetch_check_agg_list_by_repo_urls(repo_urls, begin_date, end_date,
                                                                     filter_opts: filter_opts, sort_opts: sort_opts,
                                                                     user_login_list: current_user_login_list)
        pull2_list = (pull2_resp&.[]('aggregations')&.[]('group_by_name')&.[]('buckets') || []).flat_map do |data|
          (data&.[]('group_by_pull_url')&.[]('buckets') || []).flat_map do |pr_data|
            (pr_data&.[]('top_hits')&.[]('hits')&.[]('hits') || []).flat_map do |hit_data|
              {
                user_login: data['key'],
                pr_url: pr_data['key'],
                pr_state: hit_data.dig('_source', 'pull_state'),
                comment_created_at: hit_data.dig('_source', 'comment_created_at'),
                comment_num: pr_data.dig('doc_count'),
                time_check_hours: time_diff_hours(hit_data.dig('_source', 'pull_created_at'),
                                                hit_data.dig('_source', 'comment_created_at'))
              }
            end
          end
        end

        pr_url_list = pull2_list.map { |data| data[:pr_url] }.compact.flatten.uniq
        pull_resp = pull_indexer.list_by_repo_urls(repo_urls, begin_date, end_date, pr_url_list: pr_url_list)
        pull_map = (pull_resp&.[]('hits')&.[]('hits') || []).each_with_object({}) do |data, hash|
          hash[data.dig('_source', 'url')] = {
            pr_user_login: data.dig('_source', 'user_login'),
            issue_num: data.dig('_source', 'linked_issues')&.first,
            commits_data: data.dig('_source', 'commits_data')
          }
        end

        commit_hash_list = pull_map.map { | key, values| values[:commits_data] }.compact.flatten.uniq
        git_resp = git_indexer.fetch_commit_agg_list_by_repo_urls(repo_urls, Time.parse('1970-01-01'), end_date,
                                                                     branch, commit_hash_list: commit_hash_list,
                                                                     agg_field: 'hash', per: commit_hash_list.length)
        git_map = (git_resp&.[]('aggregations')&.[]('group_by_name')&.[]('buckets') || []).each_with_object({}) do |data, hash|
          hash[data['key'].gsub(".git", "")] = {
            lines_added: data['lines_added']['value'],
            lines_removed: data['lines_removed']['value'],
            lines_changed: data['lines_changed']['value'],
          }
        end

        pull_map.map do |key, value|
          commits_data = value[:commits_data]
          value[:lines_added] = commits_data.sum { |commit_hash| git_map.dig(commit_hash, :lines_added).to_i }
          value[:lines_removed] = commits_data.sum { |commit_hash| git_map.dig(commit_hash, :lines_removed).to_i }
          value[:lines_changed] = commits_data.sum { |commit_hash| git_map.dig(commit_hash, :lines_changed).to_i }
        end

        items = pull2_list.map do |data|
          next if (pull_map.dig(data[:pr_url], :lines_changed) || 0) == 0
          updated_data = data.merge(
            pr_user_login: pull_map.dig(data[:pr_url], :pr_user_login),
            issue_num: pull_map.dig(data[:pr_url], :issue_num),
            lines_added: pull_map.dig(data[:pr_url], :lines_added),
            lines_removed: pull_map.dig(data[:pr_url], :lines_removed)
          )
          updated_data
        end
        items = items.compact.uniq

        user_login_group = items.group_by { |item| item[:user_login] }
        current_page = current_user_login_list.map do |data|
          user_login_pr_list = user_login_group.dig(data) || []
          {
            user_login: data,
            comment_num: user_login_pr_list.sum { |pr_item| pr_item.dig(:comment_num).to_i },
            time_check_hours: user_login_pr_list.sum { |pr_item| pr_item.dig(:time_check_hours).to_f },
            lines_added: user_login_pr_list.sum { |pr_item| pr_item.dig(:lines_added).to_i },
            lines_removed: user_login_pr_list.sum { |pr_item| pr_item.dig(:lines_removed).to_i },
          }
        end

        count = user_login_list.length

        { count: count, total_page: (count.to_f/per).ceil, page: page, items: current_page }
      end
    end
  end
end
