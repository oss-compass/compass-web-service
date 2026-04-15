# frozen_string_literal: true

module Openapi
  module CompassController

    class DashboardAlertController < Grape::API

      # version 'compass', using: :path
      prefix :services
      format :json

      helpers Openapi::SharedParams::Search

      helpers Openapi::V1::Helpers
      # helpers Openapi::SharedParams::ErrorHelpers
      helpers Openapi::SharedParams::RestapiHelpers

      # rescue_from :all do |e|
      #   case e
      #   when Grape::Exceptions::ValidationErrors
      #     handle_validation_error(e)
      #   when SearchFlip::ResponseError
      #     handle_open_search_error(e)
      #   else
      #     handle_generic_error(e)
      #   end
      # end
      INDEX_CLASS_MAPPING = {
        'compass_metric_model_v2_response_timeliness' => ResponseTimelinessMetric,
        'compass_metric_model_v2_collaboration_quality' => CollaborationQualityMetric,
        'compass_metric_model_v2_developer_base' => DeveloperBaseMetric,
        'compass_metric_model_v2_contribution_activity' => ContributionActivityMetric,
        'compass_metric_model_v2_community_popularity' => CommunityPopularityMetric,
        'compass_metric_model_v2_organizational_governance' => OrganizationalGovernanceMetric,
        'compass_metric_model_v2_personal_governance' => PersonalGovernanceMetric
      }.freeze

      before { require_login! }

      helpers do
        include Pagy::Backend

        def paginate_fun(scope)
          pagy(scope, page: params[:page], items: params[:per_page])
        end

        def fetch_metrics_by_range(db_index_key, label, start_date, end_date,level)

          return {} if db_index_key.blank? || label.blank?
          metric_class = INDEX_CLASS_MAPPING[db_index_key]

          real_index_name = metric_class ? metric_class.index_name : db_index_key

          begin
            # response = metric_class
            #              .must(terms: { "label.keyword" => label })
            #              .range(:grimoire_creation_date, gte: start_date, lte: end_date)
            #              .sort(grimoire_creation_date: :asc)
            #              .limit(100)
            #              .execute
            #              .raw_response
            #
            # hits = response&.[]('hits')&.[]('hits') || []

            query = metric_class
                      .must(terms: { "label.keyword" => label })
                      .range(:grimoire_creation_date, gte: start_date, lte: end_date)
                      .sort(grimoire_creation_date: :asc)
                      .limit(100)

            if level == 'community'
              query = query.must(term: { "type.keyword"=> "software-artifact" })
            end
            response = query.execute.raw_response
            hits = response&.[]('hits')&.[]('hits') || []
            hits.map { |data| data["_source"] }
          rescue => e
            Rails.logger.error "SearchFlip Range Query Error [#{real_index_name}]: #{e.message}"
            []
          end
        end


        def validate_no_overlap(organizations)
          return if organizations.size <= 1

          sorted = organizations.sort_by { |o| Date.parse(o[:first_date] || o['first_date']) }

          sorted.each_cons(2) do |current, next_org|
            current_end = current[:last_date] || current['last_date']
            next_start = next_org[:first_date] || next_org['first_date']

            if current_end.blank? || Date.parse(current_end) >= Date.parse(next_start)
              error!({ error: 'Organization date ranges overlap' }, 400)
            end
          end
        end



        # 检查当前用户是否在看板中（任何角色）
        def require_dashboard_member!(dashboard)
          return dashboard if dashboard.public?
          member = dashboard.dashboard_members.find_by(user: current_user, status: :active)
          error!({ error: '无权访问此看板' }, 403) unless member
          member
        end

        # 检查编辑权限
        def require_dashboard_editor!(dashboard)
          member = dashboard.dashboard_members.find_by(user: current_user, status: :active)
          error!({ error: '需要编辑权限' }, 403) unless member&.can_edit?
          member
        end

        # 检查管理员权限
        def require_dashboard_admin!(dashboard)
          member = dashboard.dashboard_members.find_by(user: current_user, status: :active)
          error!({ error: '需要管理员权限' }, 403) unless member&.can_manage_members?
          member
        end

        # 获取当前用户在看板中的角色
        def current_member_role(dashboard)
          dashboard.dashboard_members.find_by(user: current_user, status: :active)&.role
        end
      end



      resource :dashboard_alert do

        desc '创建预警规则',
             tags: ['DashboardAlertService / 预警服务'],
             hidden: true

        params do
          requires :dashboard_id, type: Integer, desc: '看板ID'
          requires :monitor_type, type: String, values: ['community', 'repo'], desc: '监控类型: community(社区), repo(仓库)'
          optional :target_repo, type: String, desc: '目标仓库地址'
          requires :metric_key, type: String, desc: '监控指标key'
          requires :time_range, type: Integer, desc: '最近几个月'
          requires :metric_name, type: String, desc: '监控指标名称'
          requires :operator, type: String, values: ['>', '>=', '<', '<=', '=', '!='], desc: '比较运算符'
          requires :threshold, type: BigDecimal, desc: '预警阈值'
          requires :level, type: String, values: ['critical', 'warning', 'info'], desc: '预警级别: critical(严重), warning(警告), info(提示)'
          optional :description, type: String, desc: '规则描述'
          optional :enabled, type: Boolean, default: true, desc: '是否启用'
        end

        post :create_rule do
          dashboard = Dashboard.find(params[:dashboard_id])
          require_dashboard_editor!(dashboard)

          # 验证repo类型时target_repo必填
          if params[:monitor_type] == 'repo' && params[:target_repo].blank?
            error!({ error: '仓库监控类型需要指定目标仓库' }, 422)
          end

          rule = DashboardAlertRule.new(
            dashboard_id: params[:dashboard_id],
            creator_id: current_user.id,
            monitor_type: DashboardAlertRule.monitor_types[params[:monitor_type]],
            target_repo: params[:target_repo],
            metric_key: params[:metric_key],
            metric_name: params[:metric_name],
            operator: params[:operator],
            threshold: params[:threshold],
            level: DashboardAlertRule.levels[params[:level]],
            description: params[:description],
            enabled: params[:enabled]
          )

          if rule.save
            present rule
          else
            error!({ error: rule.errors.full_messages.join(', ') }, 422)
          end
        end

        desc '更新预警规则',
             tags: ['DashboardAlertService / 预警服务'],
             hidden: true

        params do
          requires :id, type: Integer, desc: '规则ID'
          optional :monitor_type, type: String, values: ['community', 'repo'], desc: '监控类型: community(社区), repo(仓库)'
          optional :target_repo, type: String, desc: '目标仓库地址'
          optional :metric_key, type: String, desc: '监控指标key'
          optional :metric_name, type: String, desc: '监控指标名称'
          requires :time_range, type: Integer, desc: '最近几个月'
          optional :operator, type: String, values: ['>', '>=', '<', '<=', '=', '!='], desc: '比较运算符'
          optional :threshold, type: BigDecimal, desc: '预警阈值'
          optional :level, type: String, values: ['critical', 'warning', 'info'], desc: '预警级别'
          optional :description, type: String, desc: '规则描述'
          optional :enabled, type: Boolean, desc: '是否启用'
        end

        post :update_rule do
          rule = DashboardAlertRule.find(params[:id])
          dashboard = rule.dashboard
          require_dashboard_editor!(dashboard)

          update_params = declared(params, include_missing: false).except(:id)

          # 转换枚举值
          if update_params[:monitor_type].present?
            update_params[:monitor_type] = DashboardAlertRule.monitor_types[update_params[:monitor_type]]
          end
          if update_params[:level].present?
            update_params[:level] = DashboardAlertRule.levels[update_params[:level]]
          end

          if rule.update(update_params)
            present rule
          else
            error!({ error: rule.errors.full_messages.join(', ') }, 422)
          end
        end

        desc '删除预警规则',
             tags: ['DashboardAlertService / 预警服务'],
             hidden: true

        params do
          requires :id, type: Integer, desc: '规则ID'
        end

        post :delete_rule do
          rule = DashboardAlertRule.find(params[:id])
          dashboard = rule.dashboard
          require_dashboard_editor!(dashboard)

          if rule.destroy
            { status: 'success', message: '预警规则已删除' }
          else
            error!({ error: '删除失败' }, 422)
          end
        end

        desc '获取预警规则列表',
             tags: ['DashboardAlertService / 预警服务'],
             hidden: true

        params do
          requires :dashboard_id, type: Integer, desc: '看板ID'
          optional :monitor_type, type: String, values: ['community', 'repo'], desc: '监控类型筛选'
          optional :level, type: String, values: ['critical', 'warning', 'info'], desc: '预警级别筛选'
          optional :enabled, type: Boolean, desc: '启用状态筛选'
          optional :page, type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, default: 10, desc: '每页数量'
        end

        post :list_rules do
          dashboard = Dashboard.find(params[:dashboard_id])
          require_dashboard_member!(dashboard)

          scope = dashboard.dashboard_alert_rules.order(created_at: :desc)

          if params[:monitor_type].present?
            scope = scope.where(monitor_type: params[:monitor_type])
          end
          if params[:level].present?
            scope = scope.where(level: params[:level])
          end
          if !params[:enabled].nil?
            scope = scope.where(enabled: params[:enabled])
          end

          pages, records = paginate_fun(scope)

          present({
                    items: records,
                    total_count: pages.count,
                    current_page: pages.page,
                    per_page: pages.items,
                    total_pages: pages.pages
                  })
        end

        desc '获取预警规则详情',
             tags: ['DashboardAlertService / 预警服务'],
             hidden: true

        params do
          requires :id, type: Integer, desc: '规则ID'
        end

        post :get_rule do
          rule = DashboardAlertRule.find(params[:id])
          dashboard = rule.dashboard
          require_dashboard_member!(dashboard)

          present rule
        end

        desc '启用/禁用预警规则',
             tags: ['DashboardAlertService / 预警服务'],
             hidden: true

        params do
          requires :id, type: Integer, desc: '规则ID'
          requires :enabled, type: Boolean, desc: '是否启用'
        end

        post :toggle_rule do
          rule = DashboardAlertRule.find(params[:id])
          dashboard = rule.dashboard
          require_dashboard_editor!(dashboard)

          if rule.update(enabled: params[:enabled])
            present rule
          else
            error!({ error: rule.errors.full_messages.join(', ') }, 422)
          end
        end

        desc '获取预警记录列表',
             tags: ['DashboardAlertService / 预警服务'],
             hidden: true

        params do
          requires :dashboard_id, type: Integer, desc: '看板ID'
          optional :rule_id, type: Integer, desc: '规则ID筛选'
          optional :level, type: String, values: ['critical', 'warning', 'info'], desc: '预警级别筛选'
          optional :page, type: Integer, default: 1, desc: '页码'
          optional :per_page, type: Integer, default: 10, desc: '每页数量'
        end

        post :list_records do
          dashboard = Dashboard.find(params[:dashboard_id])
          require_dashboard_member!(dashboard)

          scope = dashboard.dashboard_alert_records
                           .joins(:dashboard_alert_rule)
                           .order(triggered_at: :desc)

          if params[:rule_id].present?
            scope = scope.where(dashboard_alert_rule_id: params[:rule_id])
          end
          if params[:level].present?
            scope = scope.where(dashboard_alert_rules: { level: params[:level] })
          end

          pages, records = paginate_fun(scope)

          present({
                    items: records.as_json(include: { dashboard_alert_rule: { only: [:id, :metric_name, :level] } }),
                    total_count: pages.count,
                    current_page: pages.page,
                    per_page: pages.items,
                    total_pages: pages.pages
                  })
        end

        desc '获取监控指标列表',
             tags: ['DashboardAlertService / 预警服务'],
             hidden: true

        params do
          requires :monitor_type, type: String, values: ['community', 'repo'], desc: '监控类型'
        end

        post :list_metrics do
          community_metrics = [
            { key: 'new_issue_count', name: '新建Issue数量' },
            { key: 'issue_resolution_percentage', name: 'Issue解决百分比' },
            { key: 'unresponsive_issue_count', name: '未响应Issues数量' },
            { key: 'avg_response_time', name: '平均响应时间' }
          ]

          repo_metrics = [
            { key: 'issue_total_count', name: 'Issue总数' },
            { key: 'issue_open_count', name: '打开Issue数量' },
            { key: 'closed_loop_rate', name: 'Issue闭环率' },
            { key: 'avg_closed_loop_time', name: '平均闭环时长' },
            { key: 'avg_first_response_time', name: 'Issue首次响应时间' },
            { key: 'open_unresponsive_count', name: '未响应Issue数量' }
          ]

          metrics = params[:monitor_type] == 'community' ? community_metrics : repo_metrics

          { metrics: metrics }
        end

      end
    end
  end
end

