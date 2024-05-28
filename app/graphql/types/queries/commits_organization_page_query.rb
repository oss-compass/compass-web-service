# frozen_string_literal: true

module Types
  module Queries
    class CommitsOrganizationPageQuery < BaseQuery

      type Types::Meta::CommitOrganizationPageType, null: false
      description 'Get commits Organization list of a repo or community'
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
        org_name_map = {}

        resp = indexer.fetch_commit_agg_list_by_repo_urls(repo_urls, begin_date, end_date, branch, agg_field: 'author_domain',
                                                          per: 10000, filter_opts: filter_opts, sort_opts: sort_opts)

        resp_count = indexer.lines_changed_count_by_repo_urls(repo_urls, begin_date, end_date, branch,
                                                              filter_opts: filter_opts, sort_opts: sort_opts)
        total_lines_changed = resp_count&.[]('aggregations')&.[]('total_lines_changed')&.[]('value') || 0

        buckets = resp&.[]('aggregations')&.[]('group_by_name')&.[]('buckets') || []
        domain_list = buckets.map { |data| data['key'] }.to_set.to_a
        domain_map = Organization.map_by_domain_list(domain_list)

        buckets.map do |data|
          if domain_map.key?(data['key'])
            org_name = domain_map.dig(data['key'], "org_name")
          else
            org_name = "unknown"
          end
          skeleton = Hash[Types::Meta::CommitOrganizationType.fields.keys.map(&:underscore).zip([])].symbolize_keys
          skeleton[:org_name] = org_name
          skeleton[:lines_added] =  data['lines_added']['value']
          skeleton[:lines_removed] =  data['lines_removed']['value']
          skeleton[:lines_changed] =  data['lines_changed']['value']
          skeleton[:lines_changed_ratio] =  total_lines_changed == 0 ? 0 : (skeleton[:lines_changed] / total_lines_changed).round(4)
          skeleton[:total_lines_changed] =  total_lines_changed
          org_name_map[org_name] =
            org_name_map[org_name] ? indexer.merge_commit_organization(org_name_map[org_name], skeleton) : skeleton
        end
        items = org_name_map.values.sort_by { |h| h[:lines_changed] }.reverse

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
