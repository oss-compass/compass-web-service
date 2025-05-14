# frozen_string_literal: true

module Openapi
  module V2
    class FinanceStandard < Grape::API
      version 'v2', using: :path
      prefix :api
      format :json

      # before { require_login! }

      helpers do
        def get_projects(new_datasets)
          filtered_rows = new_datasets.map do |row|
            row.to_h.merge(label: ShortenedLabel.normalize_label(row[:label]))
          end
          raise ValidateFailed.new(I18n.t('lab_models.invalid_dataset')) if filtered_rows.blank?
          filtered_rows
        end
      end

      resource :financeStandardProjectVersion do
        # desc 'trigger FinanceStandard Project'
        desc '触发执行金融指标', { tags: ['Finance Standard Metric'] }
        params do
          requires :datasets, type: Array, desc: '数据集列表', documentation: { param_type: 'body', example: [{ label: 'https://github.com/rabbitmq/rabbitmq-server', versionNumber: 'v4.0.7' }] } do
            requires :label, type: String, desc: '仓库地址', documentation: { example: 'https://github.com/rabbitmq/rabbitmq-server' }
            requires :versionNumber, type: String, desc: '版本号', documentation: { example: 'v4.0.7' }
          end
        end
        post :trigger do
          status = nil
          datasets = params[:datasets]
          projects = get_projects(datasets)

          model = LabModel.find_by(id: 298)
          version = LabModelVersion.find_by(id: 358)

          projects.each do |project|
            status = CustomAnalyzeProjectVersionServer.new(user: nil, model: model, version: version, project: project[:label], version_number: project['versionNumber'], level: 'repo').execute
          end
          status
        end

        # desc 'query trigger status for a given project'
        desc '获取给定项目的金融指标执行状态', { tags: ['Finance Standard Metric'] }
        params do
          requires :label, type: String, desc: '项目地址', documentation: { param_type: 'query', example: 'https://github.com/rabbitmq/rabbitmq-server' }
          optional :versionNumber, type: String, desc: '版本号', documentation: { param_type: 'query', example: 'v4.0.7' }
        end
        post :statusQuery do
          label = ShortenedLabel.normalize_label(params[:label])
          version_number = params[:versionNumber]
          model = LabModel.find_by(id: 298)
          version = LabModelVersion.find_by(id: 358)
          status = CustomAnalyzeProjectVersionServer.new(user: nil, model: model, version: version, project: label,
                                                         version_number: version_number, level: 'repo').check_task_status_query

          { trigger_status: status }
        end
      end

    end
  end
end
