# frozen_string_literal: true

module Types
  module Queries
    class CommunityOverviewQuery < BaseQuery
      include Common
      include Director

      OVERVIEW_CACHE_KEY = 'compass-group-overview'

      type Types::CommunityOverviewType, null: false
      description 'Get overview data of a community'
      argument :label, String, required: true, description: 'community label'
      argument :page, Integer, required: false, description: 'page number'
      argument :per, Integer, required: false, description: 'per page number'

      def resolve(label: nil, page: 1, per: 9)
        project = ProjectTask.find_by(project_name: label)
        skeleton = Hash[Types::CommunityOverviewType.fields.keys.zip([])].symbolize_keys
        result =
          if project
            repo_list = director_repo_list(project&.remote_url)
            current_page = repo_list.in_groups_of(per)&.[]([page.to_i - 1, 0].max) || []
            gitee_repos = filter_by_origin(current_page, /gitee\.com/)
            github_repos = filter_by_origin(current_page, /github\.com/)
            resp = GithubRepo.only(github_repos)
            resp2 = GiteeRepo.only(gitee_repos)
            skeleton['trends'] = build_github_repo(resp).map { |repo| OpenStruct.new(repo) }
            skeleton['trends'] += build_gitee_repo(resp2).map { |repo| OpenStruct.new(repo) }
            skeleton['projects_count'] = repo_list.length
            skeleton
          else
            skeleton['projects_count'] = 0
            skeleton['trends'] = []
            skeleton
          end
        OpenStruct.new(result)
      end
    end
  end
end
