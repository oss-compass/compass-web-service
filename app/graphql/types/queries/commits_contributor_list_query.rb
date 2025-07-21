# frozen_string_literal: true

module Types
  module Queries
    class CommitsContributorListQuery < BaseQuery

      type [Types::Meta::CommitContributorType], null: false
      description 'Get Top20 commits Contributor list of a repo or community'
      argument :label, String, required: true, description: 'repo or project label'
      argument :level, String, required: false, description: 'repo or community', default_value: 'repo'
      argument :branch, String, required: false, description: 'commit branch', default_value: 'master'
      argument :begin_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'begin date'
      argument :end_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'end date'

      def resolve(label: nil, level: 'repo', branch: 'master', begin_date: nil, end_date: nil)
        label = ShortenedLabel.normalize_label(label)

        login_required!(context[:current_user])
        validate_by_label!(context[:current_user], label)

        begin_date, end_date, interval = extract_date(begin_date, end_date)

        indexer, repo_urls =
                 select_idx_repos_by_lablel_and_level(label, level, GiteeGitEnrich, GithubGitEnrich, GitcodeGitEnrich)

        resp = indexer.fetch_commit_agg_list_by_repo_urls(repo_urls, begin_date, end_date, branch, agg_field: 'author_email',
                                                          per: 20, filter_opts: [], sort_opts: [])
        buckets = resp&.[]('aggregations')&.[]('group_by_name')&.[]('buckets') || []

        domain_list = buckets.map { |data| data['author_domain']['hits']['hits'][0]['_source']['author_domain'] }.to_set.to_a
        domain_map = Organization.map_by_domain_list(domain_list)

        items =
          buckets.map do |data|
          skeleton = Hash[Types::Meta::CommitContributorType.fields.keys.map(&:underscore).zip([])].symbolize_keys
          skeleton[:author_email] = data['key']
          skeleton[:org_name] = domain_map.dig(data['author_domain']['hits']['hits'][0]['_source']['author_domain'], "org_name")
          skeleton[:lines_added] = data['lines_added']['value']
          skeleton[:lines_removed] = data['lines_removed']['value']
          skeleton[:lines_changed] = data['lines_changed']['value']
          skeleton
          end
        items
      end
    end
  end
end
