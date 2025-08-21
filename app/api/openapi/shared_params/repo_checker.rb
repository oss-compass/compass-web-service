# frozen_string_literal: true
module Openapi
  module SharedParams
    module RepoChecker

      extend CompassUtils

      def self.check_repo!(label, level, current_user)
        exist_flag = true
        message = nil
        # 检查 项目是否存在
        repo_indexer, project_urls = select_idx_repos_by_lablel_and_level(label, level, GiteeRepoEnrich, GithubRepoEnrich, GitcodeRepoEnrich)
        exist = repo_indexer.check_exist(project_urls)

        unless exist
          # 地址格式校验（只允许 GitHub / Gitee / GitCode）
          valid_urls = project_urls.any? do |url|
            url =~ %r{\Ahttps?://(github\.com|gitee\.com|gitcode\.com)/[\w\-.]+/[\w\-.]+\z}i
          end

          unless valid_urls
            return false, "仓库地址无效（仅支持 GitHub/Gitee/GitCode 仓库）。"
          end

          # 检查项目是否可以访问 如果不可访问或者404直接返回
          accessible = project_urls.any? do |url|
            begin
              conn = Faraday.new(url: url) do |f|
                f.options.timeout = 5
                f.options.open_timeout = 3
              end
              res = conn.head
              # 2xx 或 3xx 认为可访问
              res.success? || res.status.to_s.start_with?('3')
            rescue Faraday::ConnectionFailed, Faraday::TimeoutError => e
              Rails.logger.warn "Repo access check failed for #{url}: #{e.class} #{e.message}"
              false
            end
          end

          unless accessible
            return false, "项目无法访问（可能已删除或地址错误）。"
          end

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
            exist_flag = false
            message = "#{result_message},请等待任务执行完毕后查询。"
          else
            exist_flag = false
            message = "查询项目尚未收录，已提交pr: #{pr_url} ,请等待pr合入后再查询。"
          end

        end
        return exist_flag, message
      end
    end
  end
end
