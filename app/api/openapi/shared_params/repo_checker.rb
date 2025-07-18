# frozen_string_literal: true
module Openapi
  module SharedParams
    module RepoChecker

      extend CompassUtils

      def self.check_repo!(label, level)
        repo_indexer, project_urls = select_idx_repos_by_lablel_and_level(label, level, GiteeRepoEnrich, GithubRepoEnrich, GitcodeRepoEnrich)
        exist = repo_indexer.check_exist(project_urls)

        unless exist
          result =
            PullServer.new(
              {
                level: 'repo',
                project_urls: project_urls,
                extra: { username: "oss-compass-bot", origin: "github" }
              }
            ).execute

          pr_url = result[:pr_url]
          message = result[:message]

          if message.present?
            return false, "#{message},请等待任务执行完毕后查询。"
          end
          return false, "查询项目尚未收录，已提交pr: #{pr_url} ,请等待pr合入后再查询。"
        end
        return true, nil
      end
    end
  end
end
