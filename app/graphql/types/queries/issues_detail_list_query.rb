# frozen_string_literal: true

module Types
  module Queries
    class IssuesDetailListQuery < BaseQuery

      type Types::Meta::IssueDetailPageType, null: false
      description 'Get overview data of a repo'
      argument :label, String, required: true, description: 'repo or project label'
      argument :level, String, required: false, description: 'repo or project', default_value: 'repo'
      argument :page, Integer, required: false, description: 'page number'
      argument :per, Integer, required: false, description: 'per page number'

      def resolve(label: nil, level: 'repo', page: 1, per: 9)
        label = normalize_label(label)

        validate_by_label!(context[:current_user], label)

        begin_date, end_date, interval = extract_date(nil, nil)

        indexer, repo_urls =
          if level == 'repo' && label =~ /gitee\.com/
            [GiteeIssueEnrich, [label]]
          elsif level == 'repo'&& label =~ /github\.com/
            [GithubIssueEnrich, [label]]
          else
            project = ProjectTask.find_by(project_name: label)
            repo_list = director_repo_list(project&.remote_url)
            origin = extract_repos_source(label, level)
            [origin == 'gitee' ? GiteeIssueEnrich : GithubIssueEnrich, repo_list]
          end

        resp = indexer.terms_by_repo_urls(repo_urls, begin_date, end_date, per: per, page: page)

        count = indexer.count_by_repo_urls(repo_urls, begin_date, end_date)

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
