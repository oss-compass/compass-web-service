# frozen_string_literal: true

module Types
  module Queries
    class RepoQuery < BaseQuery
      type Types::RepoType, null: true
      description 'Get repo data by specified url'
      argument :url, String, required: true, description: 'repo url'

      def resolve(url:)
        uri = Addressable::URI.parse(url)
        repo_url = "https://#{uri&.normalized_host}#{uri&.path}"
        domain = uri&.normalized_host
        case domain
        when 'gitee.com'
          {}
        when 'github.com'
          resp =
            GithubRepo
              .must(match: { origin: repo_url })
              .sort(metadata__updated_on: 'desc').page(1).per(1)
              .source(['origin',
                       'backend_name',
                       'data.name',
                       'data.language',
                       'data.full_name',
                       'data.forks_count',
                       'data.subscribers_count',
                       'data.stargazers_count',
                       'data.open_issues_count',
                       'data.created_at',
                       'data.updated_at'])
              .execute
              .raw_response
          OpenStruct.new(build_github_repo(resp).first)
        else
        end
      end
    end
  end
end
