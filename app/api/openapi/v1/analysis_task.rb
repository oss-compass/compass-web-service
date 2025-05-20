module Openapi
  module V1
    class AnalysisTask < Grape::API
      ADMIN_WEB_TOKEN = ENV.fetch('ADMIN_WEB_TOKEN')
      version 'v1', using: :path
      format :json
      prefix :api

      before do
        auth_header = headers['Authorization']
        token_match = auth_header&.match(/Bearer\s+(.+)/)
        authenticated = token_match ? token_match[1] == ADMIN_WEB_TOKEN : false
        error!("401 Unauthorized", 401) unless authenticated
      end

      resource :analysis_task do
        desc 'Create analysis task by label and level', hidden: true
        params do
          requires :label, type: String, desc: 'repo label (repo url)', documentation: { param_type: 'body' }
          optional :level, type: String, desc: 'level (repo/community), default: repo',  documentation: { param_type: 'body' }
        end
        post do
          json = JSON.parse(request.body.read)
          Rails.logger.info("AnalysisTask recving payload is: #{json}")
          label = json['label']
          level = json['level'] || 'repo'
          label = ShortenedLabel.normalize_label(label)
          if level == 'repo'
            uri = Addressable::URI.parse(label)
            unless Common::SUPPORT_DOMAINS.include?(uri&.normalized_host)
              return error!(I18n.t('analysis.validation.not_support', source: label), 400)
            end
            ::Subject.find_or_create_by(label: label, level: 'repo') do |subject|
              subject.level = 'repo'
              subject.status = ::Subject::PENDING
              subject.count = 1
              subject.status_updated_at = Time.current
            end
            AnalyzeServer.new(repo_url: label).execute(only_validate: false)
          else
            task = ProjectTask.find_by(project_name: label)
            return error!('Not Found', 404) unless task.present?
            AnalyzeGroupServer.new(yaml_url: task.remote_url).execute(only_validate: false)
          end
        end
      end
    end
  end
end
