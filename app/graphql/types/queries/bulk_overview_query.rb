# frozen_string_literal: true

module Types
  module Queries
    class BulkOverviewQuery < BaseQuery
      MAX_BULK_LIMIT = 100
      include Common

      type [Types::RepoType], null: false
      description 'Get bulk reports for a label list'
      argument :labels, [String], required: true, description: 'a list of label'

      def resolve(labels: )
        raise GraphQL::ExecutionError, I18n.t('basic.too_long', long: MAX_BULK_LIMIT) if labels.length > MAX_BULK_LIMIT
        result =
          if labels.present?
            gitee_repos = labels.select {|row| row =~ /gitee\.com/ }
            github_repos = labels.select {|row| row =~ /github\.com/ }
            resp = GithubRepo.only(github_repos)
            resp2 = GiteeRepo.only(gitee_repos)
            candidates = build_github_repo(resp).map { |repo| OpenStruct.new(repo) }
            candidates += build_gitee_repo(resp2).map { |repo| OpenStruct.new(repo) }
          else
            []
          end
      end
    end
  end
end
