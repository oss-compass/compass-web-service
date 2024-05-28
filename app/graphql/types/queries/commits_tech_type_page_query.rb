# frozen_string_literal: true

module Types
  module Queries
    class CommitsTechTypePageQuery < BaseQuery

      type Types::Meta::CommitTechTypePageType, null: false
      description 'Get commits tech type list of a repo or community'
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

        indexer, repo_urls =
                 select_idx_repos_by_lablel_and_level(label, level, GiteeGitEnrich, GithubGitEnrich)

        repo_extension_resp = RepoExtension.list_by_repo_urls(repo_urls, filter_opts: filter_opts)
        repo_extension_hits = repo_extension_resp&.[]('hits')&.[]('hits') || []
        map_technology_type = repo_extension_hits.group_by { |item| item.dig('_source', 'repo_technology_type') }
                                  .transform_values { |items| items.map { |item| item.dig('_source', 'repo_name') } }

        current_technology_type_list = (map_technology_type.keys.in_groups_of(per)&.[]([page.to_i - 1, 0].max) || []).compact
        current_repo_urls = current_technology_type_list.map { |key| map_technology_type[key] }.flatten

        commit_resp = indexer.fetch_commit_agg_list_by_repo_urls(
          current_repo_urls, begin_date, end_date, branch, per: current_repo_urls.length,
          filter_opts: filter_opts, sort_opts: sort_opts)

        buckets = commit_resp&.[]('aggregations')&.[]('group_by_name')&.[]('buckets') || []
        repo_commit_map = buckets.each_with_object({}) do |data, hash|
          hash[data['key'].gsub(".git", "")] = {
            'lines_added' => data['lines_added']['value'],
            'lines_removed' => data['lines_removed']['value'],
            'lines_changed' => data['lines_changed']['value'],
          }
        end

        current_page = current_technology_type_list.map do |key|
          values = map_technology_type[key]
          {
            repo_technology_type: key,
            lines_added: values.sum { |value| repo_commit_map.dig(value, 'lines_added') || 0 },
            lines_removed: values.sum { |value| repo_commit_map.dig(value, 'lines_removed') || 0 },
            lines_changed: values.sum { |value| repo_commit_map.dig(value, 'lines_changed') || 0 }
          }
        end

        count = map_technology_type.length

        { count: count, total_page: (count.to_f/per).ceil, page: page, items: current_page }
      end

    end
  end
end
