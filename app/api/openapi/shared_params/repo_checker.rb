# frozen_string_literal: true
module Openapi
  module SharedParams
    module RepoChecker

      extend CompassUtils

      def self.check_repo!(label, level)
        repo_indexer, project_urls = select_idx_repos_by_lablel_and_level(label, level, GiteeRepoEnrich, GithubRepoEnrich)
        exist = repo_indexer.check_exist(project_urls)

        unless exist
          result =
            PullServer.new(
              {
                level: 'repo',
                project_urls: project_urls,
                extra: { username: "system", origin: "github" }
              }
            ).execute

          # pr_status = result[:status]
          # pr_message = result[:message]

          throw :error, status: 404, message: "查询项目尚未收录，已提交pr,请等待pr合入后再查询。"
        end

      end
    end
  end
end
