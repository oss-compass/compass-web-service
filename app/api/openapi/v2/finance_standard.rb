# frozen_string_literal: true

module Openapi
  module V2
    class FinanceStandard < Grape::API
      version 'v2', using: :path
      prefix :api
      format :json


      helpers Openapi::SharedParams::AuthHelpers
      helpers Openapi::SharedParams::ErrorHelpers

      rescue_from :all do |e|
        case e
        when Grape::Exceptions::ValidationErrors
          handle_validation_error(e)
        when SearchFlip::ResponseError
          handle_open_search_error(e)
        else
          handle_generic_error(e)
        end
      end

      before { require_token! }
      before do
        token = params[:access_token]
        Openapi::SharedParams::RateLimiter.check_token!(token)
      end

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
        desc '触发执行金融指标', tags: ['场景调用'], success: {
          code: 201, model: Openapi::Entities::TriggerResponse
        }, detail: <<~DETAIL
          该接口用于触发金融指标的执行分析。
          请求参数说明：
          datasets (数组)：必填。数据集列表，每个元素包含：
            label (字符串)：仓库地址，例如 "https://github.com/rabbitmq/rabbitmq-server"
            versionNumber (字符串)：版本号，例如 "v4.0.7"

          接口逻辑说明：
          根据传入的数据集信息，提交任务，调用金融指标模型进行处理。

          返回值：
           status (布尔值)：状态值，表示分析任务是否提交成功。
        DETAIL
        params do
          requires :access_token, type: String, desc: 'access token', documentation: { param_type: 'body' }
          requires :datasets, type: Array, desc: '数据集列表', documentation: { param_type: 'body', example: [{ label: 'https://github.com/rabbitmq/rabbitmq-server', versionNumber: 'v4.0.7' }] } do
            requires :label, type: String, desc: '仓库地址', documentation: { param_type: 'body', example: 'https://github.com/rabbitmq/rabbitmq-server' }
            requires :versionNumber, type: String, desc: '版本号', documentation: { param_type: 'body', example: 'v4.0.7' }
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
        desc '获取给定项目的金融指标执行状态', tags: ['场景调用'], success: {
          code: 201, model: Openapi::Entities::StatusQueryResponse
        }, detail: <<~DETAIL
           该接口用于查询指定项目及版本号的金融指标执行状态。

           请求参数说明：
            label (字符串)：必填。项目地址，如 "https://github.com/rabbitmq/rabbitmq-server"
            versionNumber (字符串)。必填：项目版本号，如 "v4.0.7"

           接口逻辑说明：
           根据传入的项目地址及版本号，查询对应金融指标分析任务的当前执行状态。

           返回值：
          trigger_status (字符串)：任务执行状态，可能的值包括：
            pending：已经提交执行队列，将要执行;
            progress：正在执行;
            success：执行完毕;
            error：执行报错;
            canceled：任务取消;
            unsumbit：未提交任务。
        DETAIL
        params do
          requires :access_token, type: String, desc: 'access token', documentation: { param_type: 'body' }
          requires :label, type: String, desc: '项目地址', documentation: { param_type: 'body', example: 'https://github.com/rabbitmq/rabbitmq-server' }
          optional :versionNumber, type: String, desc: '版本号', documentation: { param_type: 'body', example: 'v4.0.7' }
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
