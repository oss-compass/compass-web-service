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
      argument :type, String, required: false, description: 'filter by community repository type'

      def resolve(label: nil, page: 1, per: 9, type: nil)
        project = ProjectTask.find_by(project_name: label)
        community_url = JSON.parse(project.extra)['community_url'] rescue nil
        skeleton = Hash[Types::CommunityOverviewType.fields.keys.zip([])].symbolize_keys

        result =
          Rails.cache.fetch("#{OVERVIEW_CACHE_KEY}-#{label}-#{page}-#{per}-#{type}", expires_in: 2.hours) do
          if project
            repo_list = director_repo_list_with_type(project&.remote_url)
            repo_list = repo_list.select { |repo| repo[:type] == type } if type && type.to_s != ''
            current_page = repo_list.in_groups_of(per)&.[]([page.to_i - 1, 0].max) || []
            current_page_with_type = current_page.group_by { |row| row.is_a?(Hash) ? row[:type] || UNKOWNN_TYPE : UNKOWNN_TYPE }

            repo_extander = -> (repo, type) do
              repo[:type] = type
              OpenStruct.new(repo)
            end
            skeleton['trends'] = []
            current_page_with_type.map do |type, repos|
              repos = repos.compact.map { |row| row[:repo] }
              gitee_repos = filter_by_origin(repos, /gitee\.com/)
              github_repos = filter_by_origin(repos, /github\.com/)
              resp = GithubRepo.only(github_repos)
              resp2 = GiteeRepo.only(gitee_repos)
              skeleton['trends'] += build_github_repo(resp).map { |repo| repo_extander.(repo, type) }
              skeleton['trends'] += build_gitee_repo(resp2).map { |repo| repo_extander.(repo, type) }
            end
            skeleton['projects_count'] = repo_list.length
            skeleton['community_url'] = community_url
            skeleton
          else
            skeleton['projects_count'] = 0
            skeleton['trends'] = []
            skeleton['community_url'] = community_url
            skeleton
          end
        end
        OpenStruct.new(result)
      end
    end
  end
end
