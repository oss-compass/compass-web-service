class YamlCheckWorker
  include Sneakers::Worker
  include Common
  include GiteeApplication
  include GithubApplication

  from_queue 'yaml_check_v1',
             :ack => true,
             :timeout_job_after => 60,
             :retry_max_times => 3

  def work(msg)
    execute(msg, true)
    ack!
  end

  def execute(msg, only_validate)
    message = JSON.parse(msg)
    payload = message['payload']
    user_agent = message['user_agent']

    pr_number = payload['iid'] || payload['number']
    diff_url = payload['pull_request']&.[]('diff_url')
    branch =
      if only_validate
        payload['pull_request']&.[]('head')&.[]('ref')
      else
        payload['pull_request']&.[]('base')&.[]('ref')
      end

    result =
      if diff_url.present?
        items = []
        each_patch_with_action(diff_url) do |patch|
          analyzer, is_org =
                    if patch.file.start_with?(SINGLE_DIR)
                      [AnalyzeServer, false]
                    elsif patch.file.start_with?(ORG_DIR)
                      [AnalyzeGroupServer, true]
                    end
          extra = {
            is_org: is_org,
            pr_number: pr_number,
            only_validate: only_validate
          }

          if analyzer
            items << analyze_or_submit_yaml_file(analyzer, user_agent, branch, patch.file, extra)
          else
            items << { status: false, message: I18n.t('yaml.path.invalid', path: patch.file) }
          end

        end
        { status: true, message: 'ok', result: items }
      else
        { status: false, message: I18n.t('yaml.diff_url.invalid') }
      end

    if result.present? && result.is_a?(Hash)
      rets = result[:result]
      if rets.present?
        system_notifies = rets.select { |ret| ret.is_a?(Hash) && ret[:status].nil? }
        normal_notifies = rets.select { |ret| ret.is_a?(Hash) && !ret[:status].nil? }
        if system_notifies.present?
          result[:result] = system_notifies
          system_slack_notify(user_agent, pr_number, result)
        end
        if normal_notifies.present?
          result[:result] = normal_notifies
          notify_on_pr(user_agent, pr_number, quote_mark(YAML.dump(result)))
        end
      end
    end
  end

  private

  def notify_on_pr(agent, pr_number, message)
    notify_method = gitee_agent?(agent) ? :gitee_notify_on_pr : :github_notify_on_pr
    self.send(notify_method, owner(agent), repo(agent), pr_number, message)
  rescue => ex
    Rails.logger.error("Failed to notify on pr #{pr_number}, #{ex.message}")
  end
end
