# frozen_string_literal: true
module Openapi
  module SharedParams
    module RepoChecker

      extend CompassUtils

      def self.check_repo!(label, level, current_user)
        repo_indexer, project_urls = select_idx_repos_by_lablel_and_level(label, level, GiteeRepoEnrich, GithubRepoEnrich)
        exist = repo_indexer.check_exist(project_urls)

        check_flag = false
        message = nil

        unless exist
          # 查看缓存是否存在 不存在再进行提交pr
          cache_key = "repo_checker:pr_submitted:#{label}"
          submit_cache = Rails.cache.read(cache_key)

          if submit_cache.present?
            return false, "项目未收录，PR 正在处理中，请稍后再试查询。"
          end

          Rails.cache.write(cache_key, label, expires_in: 7.days)

          user_name = current_user.login_binds.first&.nickname
          result =
            PullServer.new(
              {
                level: 'repo',
                project_urls: project_urls,
                extra: { username: user_name, origin: "github" }
              }
            ).execute

          pr_url = result[:pr_url]
          result_message = result[:message]

          if result_message.present?
            check_flag = false
            message = "#{result_message},请等待任务执行完毕后查询。"
          else
            check_flag = false
            message = "查询项目尚未收录，已提交pr: #{pr_url} ,请等待pr合入后再查询。"
          end

        end
        return check_flag, message
      end
    end
  end
end
