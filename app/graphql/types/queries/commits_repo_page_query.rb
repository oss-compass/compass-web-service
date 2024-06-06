# frozen_string_literal: true

module Types
  module Queries
    class CommitsRepoPageQuery < BaseQuery

      type Types::Meta::CommitRepoPageType, null: false
      description 'Get commits list of a repo or community'
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

        resp = indexer.fetch_commit_agg_list_by_repo_urls(repo_urls, begin_date, end_date, branch, agg_field: 'tag',
                                                          per: 10000, filter_opts: filter_opts, sort_opts: sort_opts,
                                                          label: label, level:level)

        repo_sig_list = SubjectSig.fetch_subject_sig_list_by_repo_urls(label, level, repo_urls, filter_opts: filter_opts)
        repo_sig_map = repo_sig_list.each_with_object({}) { |hash, map| map[hash[:label]] = hash }


        repo_extension_resp = RepoExtension.list_by_repo_urls(repo_urls, filter_opts: filter_opts)
        repo_extension_hits = repo_extension_resp&.[]('hits')&.[]('hits') || []
        repo_extension_map = repo_extension_hits.each_with_object({}) { |hash, map|
          map[hash['_source']['repo_name']] = hash['_source'] }

        buckets = resp&.[]('aggregations')&.[]('group_by_name')&.[]('buckets') || []
        items =
          buckets.map do |data|
            skeleton = Hash[Types::Meta::CommitRepoType.fields.keys.map(&:underscore).zip([])].symbolize_keys
            repo_name = data['key'].gsub(".git", "")
            skeleton[:repo_name] = repo_name
            skeleton[:repo_attribute_type] = repo_extension_map.dig(repo_name, 'repo_attribute_type')
            skeleton[:lines_added] = data['lines_added']['value']
            skeleton[:lines_removed] = data['lines_removed']['value']
            skeleton[:lines_changed] = data['lines_changed']['value']
            skeleton[:sig_name] = repo_sig_map.dig(repo_name, :sig_name)
            skeleton
          end

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
