# frozen_string_literal: true

module Types
  module Queries
    class CommunityOverviewQuery < BaseQuery
      include Common

      OVERVIEW_CACHE_KEY = 'compass-group-overview'

      type Types::CommunityOverviewType, null: false
      description 'Get overview data of a community'
      argument :label, String, required: true, description: 'community label'
      argument :page, Integer, required: false, description: 'page number'
      argument :per, Integer, required: false, description: 'per page number'

      def resolve(label: nil, page: 1, per: 9)
        # result =
        # Rails.cache.fetch(
        #   "#{OVERVIEW_CACHE_KEY}-#{__method__}-#{label}-#{page}-#{per}",
        #   expires_in: 2.minutes
        # ) do
        project = ProjectTask.find_by(project_name: label)
        skeleton = Hash[Types::CommunityOverviewType.fields.keys.zip([])].symbolize_keys
        result =
          if project
            repo_list =
              begin
                Rails.cache.fetch("#{OVERVIEW_CACHE_KEY}-#{__method__}-#{label}-list", expires_in: 15.minutes) do
                  encode_url = URI.encode_www_form_component(project.remote_url)
                  response =
                    Faraday.get(
                      "#{CELERY_SERVER}/api/compass/#{encode_url}/repositories",
                      { 'Content-Type' => 'application/json' }
                    )
                  repo_resp = JSON.parse(response.body)
                  repo_resp.inject([]) do |sum, (_, resource)|
                    sum + resource.map { |_, list| list }
                  end.flatten.uniq
                end
              rescue => ex
                Rails.logger.error("failed to retrive repositories, error: #{ex.message}")
                []
              end
            current_page = repo_list.in_groups_of(per)&.[]([page.to_i - 1, 0].max) || []
            gitee_repos = current_page.select {|row| row =~ /gitee\.com/ }
            github_repos = current_page.select {|row| row =~ /github\.com/ }
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
        # end
        OpenStruct.new(result)
      end
    end
  end
end
