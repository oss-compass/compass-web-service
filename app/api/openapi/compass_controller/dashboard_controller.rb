# frozen_string_literal: true

module Openapi
  module CompassController

    class DashboardController < Grape::API

      # version 'compass', using: :path
      prefix :services
      format :json

      helpers Openapi::SharedParams::Search

      helpers Openapi::V1::Helpers
      helpers Openapi::SharedParams::ErrorHelpers
      helpers Openapi::SharedParams::RestapiHelpers

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

      helpers do
        include Pagy::Backend

        def paginate_fun(scope)
          pagy(scope, page: params[:page], items: params[:per_page])
        end

      end

      before { require_login! }

      resource :dashboard do

        desc '创建看板',
             tags: ['CompassService / Compass服务'],
        hidden:true

        params do
          requires :name, type: String, desc: '看板名称',
                   documentation: { example: '核心业务监控看板' }

          requires :dashboard_type, type: String, desc: '类型 (community, repo)',
                   documentation: { example: 'repo' }

          requires :repo_urls, type: Array[String], desc: '仓库地址',
                   documentation: { param_type: 'body', example: ['https://github.com/rails/rails'] }

          optional :competitor_urls, type: Array[String], desc: '竞品地址',
                   documentation: { param_type: 'body', example: ['https://github.com/python/cpython'] }

          optional :dashboard_models_attributes, type: Array, desc: '看板模型属性' do
            documentation = {
              param_type: 'body',
              example: [
                { name: '社区活跃度模型', description: '分析 GitHub 数据', dashboard_model_info_id: 1 }
              ]
            }
            requires :name, type: String
            optional :description, type: String
            optional :dashboard_model_info_id, type: Integer
            optional :dashboard_model_info_ident, type: String
          end

          optional :dashboard_metrics_attributes, type: Array, desc: '看板指标属性' do
            documentation = {
              param_type: 'body',
              example: [
                { name: 'Star 总数', from_model: true, dashboard_model_id: 101, sort: 1 ,hidden: false,dashboard_metric_info_ident: "oo1"}
              ]
            }
            requires :name, type: String
            requires :dashboard_metric_info_ident, type: String
            optional :dashboard_model_info_ident, type: String
            optional :from_model, type: Boolean, default: false
            optional :hidden, type: Boolean, default: false
            # optional :dashboard_model_id, type: Integer
            optional :sort, type: Integer, default: 0
          end
        end

        post :create do
          # 过滤并提取参数
          dashboard_params = declared(params, include_missing: false)

          # 注入当前登录用户 ID
          dashboard_params[:user_id] = current_user.id

          # 使用 Dashboard.new 构建（如果模型里配置了 accepts_nested_attributes_for，关联表也会自动创建）
          dashboard = Dashboard.new(dashboard_params)

          if dashboard.save
            present dashboard
          else
            error!({ error: dashboard.errors.full_messages.join(', ') }, 422)
          end
        end

        desc '修改看板', tags: ['CompassService / Compass服务'],
             hidden:true

        params do
          requires :id, type: Integer, desc: '看板 ID',
                   documentation: { example: 4 }

          optional :name, type: String, desc: '看板名称',
                   documentation: { example: '更新后的核心业务看板' }

          optional :dashboard_type, type: String, values: ['community', 'repo'],
                   desc: '类型', documentation: { example: 'community' }

          optional :repo_urls, type: Array[String], desc: '仓库地址',
                   documentation: { param_type: 'body', example: ['https://github.com/new-repo'] }

          optional :competitor_urls, type: Array[String], desc: '竞品地址',
                   documentation: { param_type: 'body', example: ['https://github.com/new-competitor'] }

          optional :dashboard_models_attributes, type: Array, desc: '看板模型属性 (全删全建)' do
            documentation = {
              param_type: 'body',
              example: [
                { name: '新模型 A', description: '更新后的描述' }
              ]
            }
            requires :name, type: String
            optional :description, type: String
            optional :dashboard_model_info_id, type: Integer
            optional :dashboard_model_info_ident, type: String
          end

          optional :dashboard_metrics_attributes, type: Array, desc: '看板指标属性 (全删全建)' do
            documentation = {
              param_type: 'body',
              example: [
                { name: '新指标 1', from_model: false, sort: 10 },
                { name: '新指标 2', from_model: true, sort: 20 }
              ]
            }
            requires :name, type: String
            optional :from_model, type: Boolean, default: false
            optional :dashboard_metric_info_ident, type: String
            optional :hidden, type: Boolean, default: false
            optional :dashboard_model_info_ident, type: String
            # optional :dashboard_model_id, type: Integer
            optional :sort, type: Integer, default: 0
          end
        end
        post :update do
          dashboard = current_user.dashboards.find(params[:id])

          update_params = declared(params, include_missing: false)

          # 分离出关联属性，避免它们直接进入 dashboard.update 触发 Rails 默认的嵌套逻辑
          models_attr = update_params.delete(:dashboard_models_attributes)
          metrics_attr = update_params.delete(:dashboard_metrics_attributes)

          # 2. 开启事务
          Dashboard.transaction do
            # 更新主表基础字段 (name, dashboard_type, urls 等)
            dashboard.update!(update_params)

            # 3. 处理模型关联：全删全建
            if models_attr.present?
              dashboard.dashboard_models.destroy_all
              models_attr.each { |attr| dashboard.dashboard_models.create!(attr) }
            end

            # 4. 处理指标关联：全删全建
            if metrics_attr.present?
              dashboard.dashboard_metrics.destroy_all
              metrics_attr.each { |attr| dashboard.dashboard_metrics.create!(attr) }
            end
          end

          # 5. 返回最新数据，包含关联
          present dashboard.as_json(include: [:dashboard_models, :dashboard_metrics])

        rescue ActiveRecord::RecordInvalid => e
          # 捕获事务中的校验错误
          error!({ error: e.record.errors.full_messages.join(', ') }, 422)
        rescue => e
          error!({ error: "更新失败: #{e.message}" }, 500)

        end

        desc '删除看板', tags: ['CompassService / Compass服务'],
             hidden:true

        params do
          requires :id, type: Integer, desc: '看板ID'
        end

        post :delete do

          dashboard = current_user.dashboards.find(params[:id])
          if dashboard.destroy
            {
              status: 'success',
              message: "看板 '#{dashboard.name}' 及其关联的指标和模型已成功删除"
            }
          else
            error!({ error: '删除失败，请稍后重试' }, 422)
          end
        rescue ActiveRecord::RecordNotFound
          error!({ error: '未找到该看板或无权操作' }, 404)
        end

        desc '获取看板列表', tags: ['CompassService / Compass服务'],
             hidden:true

        params do
          optional :page, type: Integer, default: 1
          optional :per_page, type: Integer, default: 10
        end
        post :list do
          dashboards_scope = current_user.dashboards
                                         .includes(:dashboard_models, :dashboard_metrics)
                                         .order(created_at: :desc)
          pages, records = paginate_fun(dashboards_scope)

          present({
                    items: records.as_json(include: [:dashboard_models, :dashboard_metrics]),
                    total_count: pages.count,
                    current_page: pages.page,
                    per_page: pages.items,
                    total_pages: pages.pages
                  })
        end

        desc '获取所有模型及指标定义 (含独立指标)',
             tags: ['CompassService / Compass服务'],
             hidden:true


        post :list_model_metric do

          models = DashboardModelInfo.includes(:dashboard_metric_infos).all

          independent_metrics = DashboardMetricInfo.where(dashboard_model_info_id: nil).all

          {
            models: models.as_json(include: {
              dashboard_metric_infos: { except: [:created_at, :updated_at] }
            }),
            independent_metrics: independent_metrics.as_json
          }

        end

        desc '通过编码获取看板详情',
             tags: ['CompassService / compass服务'],
             hidden:true


        params do
          requires :identifier, type: String, desc: '看板唯一编码'
        end

        post :get_by_identifier do
          dashboard = current_user.dashboards.includes(:dashboard_models, :dashboard_metrics)
                               .find_by!(identifier: params[:identifier])

          present dashboard.as_json(include: [:dashboard_models, :dashboard_metrics])
        end

      end
    end
  end
end

