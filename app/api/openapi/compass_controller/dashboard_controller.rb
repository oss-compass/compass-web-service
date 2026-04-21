# frozen_string_literal: true

module Openapi
  module CompassController

    class DashboardController < Grape::API

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

        # UUID 生成方法
        def generate_uuid(contributor, modify_type, label, level, platform)
          Digest::MD5.hexdigest("#{contributor}:#{modify_type}:#{label}:#{level}:#{platform}")
        end

        def clear_all_contributors_cache(repo_urls)
          repos_string = repo_urls.sort.join(',')
          repos_hash = Digest::MD5.hexdigest(repos_string)
          pattern = "contributors:#{repos_hash}:*"
          Rails.cache.delete_matched(pattern)
        end

        # 检查当前用户是否在看板中（任何角色）
        def require_dashboard_member!(dashboard)
          member = dashboard.dashboard_members.find_by(user: current_user, status: :active)

          if dashboard.public?
            member  # 公开看板：返回 member 或 nil
          else
            error!({ error: '无权访问此看板' }, 403) unless member
            member
          end
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



      resource :dashboard do

        desc '创建看板',
             tags: ['CompassService / Compass服务'],
             hidden: true

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
                { name: 'Star 总数', from_model: true, dashboard_model_id: 101, sort: 1, hidden: false, dashboard_metric_info_ident: "oo1" }
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
            dashboard.dashboard_members.create!(
              user_id: current_user.id,
              role: 2,
              status: 0,
              invited_by_id: current_user.id,
              joined_at: Time.current,
              remark: '看板创建者'
            )

            present dashboard

          else
            error!({ error: dashboard.errors.full_messages.join(', ') }, 422)
          end
        end

        desc '修改看板', tags: ['CompassService / Compass服务'],
             hidden: true

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
             hidden: true

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
             hidden: true

        params do
          optional :page, type: Integer, default: 1
          optional :per_page, type: Integer, default: 10
          optional :keyword, type: String, desc: '名称搜索关键词'
          optional :dashboard_type, type: String, values: %w[community repo], desc: '看板类型筛选: community, repo '
          optional :sort_by, type: String, default: 'created_at', values: %w[created_at updated_at name], desc: '排序字段'
          optional :sort_direction, type: String, default: 'desc', values: %w[asc desc], desc: '排序方向'
        end
        post :list do

          base_scope = Dashboard.left_joins(:dashboard_members)
                                .where('dashboards.user_id = ? OR (dashboard_members.user_id = ? AND dashboard_members.status = ?)',
                                       current_user.id, current_user.id, DashboardMember.statuses[:active])
                                .distinct

          dashboards_scope = base_scope

          if params[:keyword].present?
            dashboards_scope = dashboards_scope.where('name LIKE ?', "%#{params[:keyword]}%")
          end

          if params[:dashboard_type].present?
            dashboards_scope = dashboards_scope.where(dashboard_type: params[:dashboard_type])
          end

          sort_column = params[:sort_by]
          sort_order = params[:sort_direction] == 'asc' ? :asc : :desc

          # 处理可能的安全问题，只允许指定字段排序
          allowed_columns = %w[created_at updated_at name]
          if allowed_columns.include?(sort_column)
            dashboards_scope = dashboards_scope.order("#{sort_column} #{sort_order}")
          else
            dashboards_scope = dashboards_scope.order(created_at: :desc)
          end

          # 预加载关联数据并分页
          dashboards_scope = dashboards_scope.includes(:dashboard_models, :dashboard_metrics)
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
             hidden: true

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
             hidden: true

        params do
          requires :identifier, type: String, desc: '看板唯一编码'
        end

        post :get_by_identifier do

          dashboard = Dashboard.includes(:dashboard_models, :dashboard_metrics)
                               .find_by!(identifier: params[:identifier])

          member  =  require_dashboard_member!(dashboard)

          level = dashboard.dashboard_type
          parsed_urls = dashboard.repo_urls.present? ? JSON.parse(dashboard.repo_urls) : []
          label = parsed_urls.first
          response_data = dashboard.as_json(include: [:dashboard_models, :dashboard_metrics])
          if level == 'community'
            origin = extract_repos_source(
              label,
              level
            )
            response_data['origin'] = origin
          end

          current_user_permissions = if member.is_a?(DashboardMember)
                                       {
                                         is_member: true,
                                         role: member.role,
                                         # permissions: {
                                         #   can_view: true,
                                         #   can_edit: member.can_edit?,
                                         #   can_manage_members: member.can_manage_members?,
                                         #   can_delete_dashboard: member.can_delete_dashboard?
                                         # }
                                       }
                                     else
                                       # 公开看板，非成员
                                       {
                                         is_member: false,
                                         role: nil,
                                         # permissions: {
                                         #   can_view: true,
                                         #   can_edit: false,
                                         #   can_manage_members: false,
                                         #   can_delete_dashboard: false
                                         # }
                                       }
                                     end
          response_data['current_user_role'] = current_user_permissions
          # present dashboard.as_json(include: [:dashboard_models, :dashboard_metrics])
          present response_data
        end

        desc '通过编码获取看板指标列表',
             tags: ['CompassService / compass服务']

        params do
          requires :identifier, type: String, desc: '看板唯一编码'
          requires :repo, type: String, desc: '仓库地址'
          optional :level, type: String, default: 'repo', desc: '级别: repo 或 community'
          requires :period, type: String, desc: '周期'
          requires :beginDate, type: String, desc: '开始时间'
          requires :endDate, type: String, desc: '结束时间'

        end

        # post :get_metrics_by_identifier do
        #
        #   dashboard = Dashboard.find_by(identifier: params[:identifier])
        #   error!({ error: '找不到该看板或无权访问' }, 403) if dashboard.blank?
        #
        #   target_label = params[:repo].presence
        #   if target_label.blank?
        #     present []
        #     return
        #   end
        #   level = params[:level]
        #
        #   metrics = dashboard.dashboard_metrics
        #                      .includes(:dashboard_metric_info)
        #                      .order(sort: :asc)
        #
        #   start_date = params[:beginDate]
        #   end_date = params[:endDate]
        #
        #
        #   repo_urls = [target_label]
        #
        #   os_data_store = {}
        #   index_scores = {}
        #   model_scores = []
        #   involved_indices = metrics.map { |m| m.dashboard_metric_info.metric_index }.uniq.compact
        #
        #   involved_indices.each do |index_name|
        #
        #     docs = fetch_metrics_by_range(index_name, repo_urls, start_date, end_date, level)
        #     os_data_store[index_name] = docs
        #
        #     matched_metric = metrics.find { |m| m.dashboard_metric_info.metric_index == index_name }
        #
        #     model_ident = matched_metric&.dashboard_model_info_ident
        #
        #     if model_ident.present?
        #       score_data = docs.map do |doc|
        #         {
        #           date: doc['grimoire_creation_date'],
        #           value: doc['score'] || 0,
        #           # extra: {}
        #         }
        #       end
        #
        #       model_scores << {
        #         id: matched_metric.dashboard_model_id,
        #         # name: matched_metric.name,
        #         ident: model_ident,
        #         data: score_data
        #       }
        #     end
        #
        #     # docs = fetch_metrics_by_range(index_name, repo_urls, start_date, end_date)
        #     # os_data_store[index_name] = docs
        #     index_scores[model_ident] = docs.map do |doc|
        #       {
        #         date: doc['grimoire_creation_date'],
        #         score: doc['score'] || 0,
        #         ident: model_ident
        #
        #       }
        #
        #     end
        #   end
        #
        #   result_list = metrics.map do |metric|
        #     info = metric.dashboard_metric_info
        #
        #     settings = if info.mapping_settings.is_a?(String)
        #                  JSON.parse(info.mapping_settings) rescue {}
        #                else
        #                  info.mapping_settings || {}
        #                end
        #
        #     source_docs = os_data_store[info.metric_index] || []
        #
        #     # 从每一个时间点的数据中提取值
        #     series_data = source_docs.map do |doc|
        #       # --- 数值计算逻辑 (复用之前的逻辑，但针对单个 doc) ---
        #       value = 0
        #       if settings['main']
        #         value = doc[settings['main']] || 0
        #       elsif settings['numerator'] && settings['denominator']
        #         num = doc[settings['numerator']].to_f
        #         den = doc[settings['denominator']].to_f
        #         value = den.zero? ? 0 : (num / den).round(4)
        #       end
        #
        #       # # --- 格式化 ---
        #       # display_value = value.to_s
        #       # if settings['unit'] == '%'
        #       #   display_value = "#{(value.to_f * 100).round(2)}%"
        #       # end
        #
        #       # --- 额外信息 ---
        #       extra = {}
        #       extra[:total] = doc[settings['total_field']] if settings['total_field']
        #       extra[:avg] = doc[settings['avg']] if settings['avg']
        #       extra[:added] = doc[settings['added']] if settings['added']
        #       extra[:unit] = settings['unit'] if settings['unit']
        #
        #       # 单条记录结构
        #       {
        #         date: doc['grimoire_creation_date'], # 数据对应的日期 (如 2025-01-01)
        #         value: value,
        #         # display_value: display_value,
        #         extra: extra
        #       }
        #     end
        #
        #     # 返回结构：包含元数据和 data 数组
        #     {
        #       id: metric.id,
        #       name: info.name,
        #       ident: info.ident,
        #       # unit: settings['unit'],
        #       #
        #       data: series_data
        #     }
        #   end
        #
        #   # present result_list
        #
        #   present({
        #             metrics: result_list,
        #             model_scores: model_scores
        #           })
        #
        # end

        post :get_metrics_by_identifier do

          dashboard = Dashboard.find_by(identifier: params[:identifier])
          error!({ error: '找不到该看板或无权访问' }, 403) if dashboard.blank?

          target_label = params[:repo].presence
          if target_label.blank?
            present []
            return
          end
          level = params[:level]

          metrics = dashboard.dashboard_metrics
                             .includes(:dashboard_metric_info)
                             .order(sort: :asc)

          start_date = params[:beginDate]
          end_date = params[:endDate]

          # 检查是否是最近3个月的查询
          begin_date_obj = Date.parse(start_date) rescue nil
          end_date_obj = Date.parse(end_date) rescue nil
          is_recent_3_months = false

          if begin_date_obj && end_date_obj
            months_diff = (end_date_obj.year - begin_date_obj.year) * 12 + (end_date_obj.month - begin_date_obj.month)
            is_recent_3_months = months_diff == 3 || (end_date_obj - begin_date_obj).to_i <= 95
          end

          repo_urls = [target_label]

          os_data_store = {}
          index_scores = {}
          model_scores = []
          involved_indices = metrics.map { |m| m.dashboard_metric_info.metric_index }.uniq.compact

          # 第一次查询
          involved_indices.each do |index_name|
            docs = fetch_metrics_by_range(index_name, repo_urls, start_date, end_date, level)
            os_data_store[index_name] = docs
          end

          # 检查是否需要重新查询：最近3个月且所有非空指标数据都只有2个
          non_empty_docs = os_data_store.values.reject { |docs| docs.empty? }
          need_refetch = is_recent_3_months && non_empty_docs.all? { |docs| docs.size == 2 } && non_empty_docs.any?

          if need_refetch
            # 开始时间往前推1个月
            new_start_date = (begin_date_obj << 1).strftime('%Y-%m-%d')

            os_data_store = {}  # 重置数据存储

            involved_indices.each do |index_name|
              docs = fetch_metrics_by_range(index_name, repo_urls, new_start_date, end_date, level)
              os_data_store[index_name] = docs
            end
          end

          involved_indices.each do |index_name|
            docs = os_data_store[index_name]

            matched_metric = metrics.find { |m| m.dashboard_metric_info.metric_index == index_name }

            model_ident = matched_metric&.dashboard_model_info_ident

            if model_ident.present?
              score_data = docs.map do |doc|
                {
                  date: doc['grimoire_creation_date'],
                  value: doc['score'] || 0,
                  # extra: {}
                }
              end

              model_scores << {
                id: matched_metric.dashboard_model_id,
                # name: matched_metric.name,
                ident: model_ident,
                data: score_data
              }
            end

            index_scores[model_ident] = docs.map do |doc|
              {
                date: doc['grimoire_creation_date'],
                score: doc['score'] || 0,
                ident: model_ident

              }

            end
          end

          result_list = metrics.map do |metric|
            info = metric.dashboard_metric_info

            settings = if info.mapping_settings.is_a?(String)
                         JSON.parse(info.mapping_settings) rescue {}
                       else
                         info.mapping_settings || {}
                       end

            source_docs = os_data_store[info.metric_index] || []

            # 从每一个时间点的数据中提取值
            series_data = source_docs.map do |doc|
              # --- 数值计算逻辑 (复用之前的逻辑，但针对单个 doc) ---
              value = 0
              if settings['main']
                value = doc[settings['main']] || 0
              elsif settings['numerator'] && settings['denominator']
                num = doc[settings['numerator']].to_f
                den = doc[settings['denominator']].to_f
                value = den.zero? ? 0 : (num / den).round(4)
              end

              # # --- 格式化 ---
              # display_value = value.to_s
              # if settings['unit'] == '%'
              #   display_value = "#{(value.to_f * 100).round(2)}%"
              # end

              # --- 额外信息 ---
              extra = {}
              extra[:total] = doc[settings['total_field']] if settings['total_field']
              extra[:avg] = doc[settings['avg']] if settings['avg']
              extra[:added] = doc[settings['added']] if settings['added']
              extra[:unit] = settings['unit'] if settings['unit']

              # 单条记录结构
              {
                date: doc['grimoire_creation_date'], # 数据对应的日期 (如 2025-01-01)
                value: value,
                # display_value: display_value,
                extra: extra
              }
            end

            # 返回结构：包含元数据和 data 数组
            {
              id: metric.id,
              name: info.name,
              ident: info.ident,
              # unit: settings['unit'],
              #
              data: series_data
            }
          end

          # present result_list

          present({
                    metrics: result_list,
                    model_scores: model_scores
                  })

        end

        desc '获取贡献者详情列表',
             tags: ['CompassService / compass服务']

        params do
          requires :label, type: String, desc: 'Repo 或 Project 的 label'
          optional :level, type: String, default: 'repo', desc: '级别: repo 或 community'
          optional :page, type: Integer, default: 1, desc: '页码'
          optional :per, type: Integer, default: 9, desc: '每页数量'
          optional :beginDate, type: String, desc: '开始日期 (ISO8601)'
          optional :endDate, type: String, desc: '结束日期 (ISO8601)'

          # 复杂对象数组，对应 GraphQL 的 [Input::FilterOptionInput]
          optional :filter_opts, type: Array do
            optional :type, type: String
            optional :values, type: Array[String]
          end

          # 排序选项，对应 GraphQL 的 [Input::SortOptionInput]
          optional :sort_opts, type: Array do
            optional :type, type: String
            optional :direction, type: String
          end
        end

        post :contributors_detail_list do

          label = ShortenedLabel.normalize_label(params[:label])
          level = params[:level]
          page = params[:page]
          per = params[:per]
          begin_date = params[:beginDate]
          end_date = params[:endDate]

          filter_opts = (params[:filterOpts] || []).map { |opt| OpenStruct.new(opt) }
          # sort_opts = (params[:sort_opts] || []).map { |opt| OpenStruct.new(opt) }
          sort_opts = [params[:sortOpts]].compact.map { |opt| OpenStruct.new(opt) }

          filter_opts << OpenStruct.new(type: "is_bot", values: ["false"])
          # # validate_by_label!(current_user, label)
          #
          # begin_date, end_date, interval = extract_date(params[:beginDate], params[:endDate])
          # validate_date!(current_user, label, level, begin_date, end_date)

          indexer, repo_urls, origin = select_idx_repos_by_lablel_and_level(
            label,
            level,
            GiteeContributorEnrich,
            GithubContributorEnrich,
            GitcodeContributorEnrich
          )

          repo_urls_filter_opt = filter_opts.find { |opt| opt.type == 'repo_urls' }
          filter_opts.delete_if { |opt| opt.type == 'repo_urls' }

          if repo_urls_filter_opt && repo_urls_filter_opt.values.present?
            repo_urls = repo_urls & repo_urls_filter_opt.values
          end

          contributors_list = indexer
                                .fetch_contributors_list(repo_urls, begin_date, end_date, label: label, level: level)
                                .then { |list| indexer.filter_contributors(list, filter_opts) }
                                .then { |list| indexer.sort_contributors(list, sort_opts) }

          count = contributors_list.length

          paged_items = (contributors_list.in_groups_of(per, false)&.[]([page - 1, 0].max) || [])
          # .map { |item| OpenStruct.new(item) }

          # 9. 返回结果
          {
            count: count,
            total_page: (count.to_f / per).ceil,
            page: page,
            items: paged_items,
            origin: origin
          }
        end

        desc '获取贡献者总览数据 (Overview): 人数统计与组织统计',
             tags: ['CompassService / compass服务']

        params do
          requires :label, type: String, desc: 'Repo 或 Project 的 label'
          optional :level, type: String, default: 'repo', desc: '级别: repo 或 community'
          optional :beginDate, type: String, desc: '开始日期 (ISO8601)'
          optional :endDate, type: String, desc: '结束日期 (ISO8601)'
        end

        post :contributors_overview do
          # 参数处理
          label = ShortenedLabel.normalize_label(params[:label])
          level = params[:level]
          begin_date = params[:beginDate]
          end_date = params[:endDate]

          # 校验逻辑 (根据需要开启)
          # validate_by_label!(current_user, label)
          # begin_date, end_date, _ = extract_date(params[:beginDate], params[:endDate])
          # validate_date!(current_user, label, level, begin_date, end_date)

          # 选择索引器
          indexer, repo_urls, _origin = select_idx_repos_by_lablel_and_level(
            label,
            level,
            GiteeContributorEnrich,
            GithubContributorEnrich,
            GitcodeContributorEnrich
          )
          filter_opts = []
          # 获取全量贡献者列表 (不分页)
          filter_opts << OpenStruct.new(type: "is_bot", values: ["false"])
          full_contributors_list = indexer.fetch_contributors_list(repo_urls, begin_date, end_date, label: label, level: level)
                                          .then { |list| indexer.filter_contributors(list, filter_opts) }

          # 1. 贡献者数量
          contributors_count = full_contributors_list.length

          # 2. Top 1 贡献者
          # 逻辑：按 commit_count 倒序排列取前1
          # 字段兼容：确保 commit_count 为数字，防止 nil 报错
          top_contributors = full_contributors_list
                               .sort_by { |c| -(c['commit_count'].to_i) }
                               .first(1)
                               # 仅返回前端需要的字段，避免暴露过多信息
                               .map do |c|
            {
              name: c['contributor']
            }
          end

          # 3. 组织统计 (聚合逻辑)
          # 逻辑：将贡献者按 company 字段分组，排除空组织，计算每个组织的贡献总量
          org_stats = Hash.new(0)

          full_contributors_list.each do |c|
            company_name = c['organization']
            # 过滤无效的组织名 (nil, 空字符串, '-', 'none' 等)
            next if company_name.blank? || %w[- none unknown].include?(company_name.downcase)

            # 累加贡献度 (这里以 commit_count 为权重，也可以改为 +1 仅统计人数)
            org_stats[company_name] += c['contribution'].to_i
          end

          # 贡献组织数量
          organizations_count = org_stats.keys.length

          # 4. Top 1 贡献组织
          # 逻辑：按贡献总量倒序排列取前1
          top_organizations = org_stats
                                .sort_by { |_name, count| -count }
                                .first(1)
                                .map { |name, count| { name: name } }

          # 返回结果
          {
            contributors_count: contributors_count, # 贡献者总数
            top_contributors: top_contributors, # Top 贡献者列表
            organizations_count: organizations_count, # 贡献组织总数
            top_organizations: top_organizations # Top 贡献组织列表
          }
        end

        desc '获取 Issue 详情列表',
             tags: ['CompassService / compass服务']

        params do
          requires :label, type: String, desc: 'Repo 或 Project 的 label'
          optional :level, type: String, default: 'repo', desc: '级别: repo 或 community'
          optional :page, type: Integer, default: 1, desc: '页码'
          optional :per, type: Integer, default: 9, desc: '每页数量'
          optional :beginDate, type: String, desc: '开始日期 (ISO8601)'
          optional :endDate, type: String, desc: '结束日期 (ISO8601)'
          optional :labelFilter, type: String, desc: '标签筛选'
          optional :filter_opts, type: Array do
            optional :type, type: String
            optional :values, type: Array[String]
          end

          optional :sort_opts, type: Array do
            optional :type, type: String
            optional :direction, type: String
          end
        end

        # post :issues_detail_list do
        #
        #   label = ShortenedLabel.normalize_label(params[:label])
        #   level = params[:level]
        #   page = params[:page]
        #   per = params[:per]
        #   begin_date = params[:beginDate]
        #   end_date = params[:endDate]
        #
        #   filter_opts = (params[:filterOpts] || []).map { |opt| OpenStruct.new(opt) }
        #   sort_opts = if params[:sortOpts].nil? || params[:sortOpts].empty?
        #                 [OpenStruct.new(type: 'created_at', direction: 'desc')]
        #               else
        #                 raw_opts = [params[:sortOpts]].flatten.compact
        #                 parsed_opts = raw_opts.map { |opt| OpenStruct.new(opt) }
        #                 has_created_at = parsed_opts.any? { |opt| opt.type == 'created_at' }
        #                 unless has_created_at
        #                   parsed_opts << OpenStruct.new(type: 'created_at', direction: 'desc')
        #                 end
        #
        #                 parsed_opts
        #               end
        #
        #   indexer, repo_urls = select_idx_repos_by_lablel_and_level(
        #     label,
        #     level,
        #     GiteeIssueEnrich,
        #     GithubIssueEnrich,
        #     GitcodeIssueEnrich
        #   )
        #
        #   filter_opts << OpenStruct.new(type: 'pull_request', values: ['false'])
        #
        #
        #
        #   org_filter_opt = filter_opts.find { |opt| opt.type == 'organization' }
        #   filter_opts.delete_if { |opt| opt.type == 'organization' }
        #
        #   target_orgs = org_filter_opt&.values || []
        #   resp = indexer.terms_by_repo_urls(
        #     repo_urls,
        #     begin_date,
        #     end_date,
        #     per: per,
        #     page: page,
        #     filter_opts: filter_opts,
        #     sort_opts: sort_opts
        #   )
        #
        #   count = indexer.count_by_repo_urls(repo_urls, begin_date, end_date, filter_opts: filter_opts)
        #
        #   # 将字段名定义为常量或局部变量，使用 String 格式匹配 _source 的 key
        #   ALLOWED_FIELDS = %w[
        #               repository
        #               id_in_repo
        #               url
        #               title
        #               state
        #               created_at
        #               closed_at
        #               time_to_close_days
        #               time_to_first_attention_without_bot
        #               labels
        #               user_login
        #               assignee_login
        #               num_of_comments_without_bot
        # ].freeze
        #
        #   hits = resp&.dig('hits', 'hits') || []
        #
        #   # 提取所有唯一的 user_login
        #   user_logins = hits.map { |hit| hit.dig('_source', 'user_login') }.compact.uniq
        #
        #   contrib_indexer, repo_urls, origin = select_idx_repos_by_lablel_and_level(
        #     label,
        #     level,
        #     GiteeContributorEnrich,
        #     GithubContributorEnrich,
        #     GitcodeContributorEnrich
        #   )
        #
        #   contributors_info = {}
        #   if user_logins.any?
        #     contributors_list = contrib_indexer.fetch_contributors_list(repo_urls, begin_date, end_date, label: label, level: level)
        #
        #     # 构建 user_login -> 贡献者信息的映射
        #     contributors_info = contributors_list.each_with_object({}) do |item, hash|
        #       login = item.respond_to?(:contributor) ? item.contributor : item['contributor']
        #       hash[login] = item if login
        #     end
        #   end
        #
        #   items = hits.map do |hit|
        #     source = hit['_source'] || {}
        #
        #     item_hash = ALLOWED_FIELDS.each_with_object({}) do |field, hash|
        #       hash[field] = source[field]
        #     end
        #
        #     if item_hash['state'] == 'closed' && item_hash['time_to_first_attention_without_bot'].nil?
        #       item_hash['time_to_first_attention_without_bot'] = 0
        #     end
        #
        #     # if item_hash['num_of_comments_without_bot'].nil?
        #     #   item_hash['num_of_comments_without_bot'] = 0
        #     # end
        #
        #     # 嵌入贡献者信息 ==========
        #     user_login = item_hash['user_login']
        #     contributor = contributors_info[user_login]
        #
        #     if contributor
        #       # 提取组织信息
        #       organization = contributor.respond_to?(:organization) ? contributor.organization : contributor['organization']
        #
        #       # 判断内外部标签
        #       is_internal = organization.to_s.downcase == 'huawei'
        #
        #       item_hash['contributor'] = {
        #         'organization' => organization,
        #         'is_internal' => is_internal
        #       }
        #     else
        #       # 如果找不到贡献者信息，设置默认值
        #       item_hash['contributor'] = {
        #         'organization' => nil,
        #         'is_internal' => false
        #       }
        #     end
        #
        #     item_hash
        #   end
        #
        #
        #   if target_orgs.present?
        #     target_orgs_lower = target_orgs.map(&:to_s).map(&:downcase)
        #     items = items.select do |item|
        #       contributor = item['contributor']
        #       org = contributor&.dig('organization')
        #       target_orgs_lower.include?(org.to_s.downcase)
        #     end
        #
        #     # 重新计算分页
        #     count = items.length
        #     total_page = (count.to_f / per).ceil
        #     page = [page, total_page].min
        #     page = 1 if page < 1
        #     start_idx = (page - 1) * per
        #     items = items[start_idx, per] || []
        #   end
        #   {
        #     count: count,
        #     total_page: (count.to_f / per).ceil,
        #     page: page,
        #     items: items
        #   }
        # end

        post :issues_detail_list do
          label = ShortenedLabel.normalize_label(params[:label])
          level = params[:level]
          page = params[:page]
          per = params[:per]
          begin_date = params[:beginDate]
          end_date = params[:endDate]


          filter_opts = (params[:filterOpts] || []).map { |opt| OpenStruct.new(opt) }
          sort_opts = if params[:sortOpts].nil? || params[:sortOpts].empty?
                        [OpenStruct.new(type: 'created_at', direction: 'desc')]
                      else
                        raw_opts = [params[:sortOpts]].flatten.compact
                        parsed_opts = raw_opts.map { |opt| OpenStruct.new(opt) }
                        has_created_at = parsed_opts.any? { |opt| opt.type == 'created_at' }
                        unless has_created_at
                          parsed_opts << OpenStruct.new(type: 'created_at', direction: 'desc')
                        end
                        parsed_opts
                      end

          indexer, repo_urls = select_idx_repos_by_lablel_and_level(
            label,
            level,
            GiteeIssueEnrich,
            GithubIssueEnrich,
            GitcodeIssueEnrich
          )

          filter_opts << OpenStruct.new(type: 'pull_request', values: ['false'])

          # 提取组织筛选条件
          org_filter_opt = filter_opts.find { |opt| opt.type == 'organization' }
          filter_opts.delete_if { |opt| opt.type == 'organization' }
          target_orgs = org_filter_opt&.values || []

          # ========== 如果有组织筛选，先获取贡献者信息 ==========
          target_user_logins = nil

          if target_orgs.present?
            contrib_indexer, repo_urls, origin = select_idx_repos_by_lablel_and_level(
              label,
              level,
              GiteeContributorEnrich,
              GithubContributorEnrich,
              GitcodeContributorEnrich
            )

            # 获取所有贡献者（不带分页，获取全部）
            all_contributors = contrib_indexer.fetch_contributors_list(
              repo_urls,
              begin_date,
              end_date,
              label: label,
              level: level
            )

            # 筛选目标组织的贡献者
            target_orgs_lower = target_orgs.map(&:to_s).map(&:downcase)

            target_user_logins = all_contributors
                                   .select do |item|
              org = item.respond_to?(:organization) ? item.organization : item['organization']
              target_orgs_lower.include?(org.to_s.downcase)
            end
                                   .map { |item| item.respond_to?(:contributor) ? item.contributor : item['contributor'] }
                                   .compact
                                   .uniq

            # 将 user_login 筛选条件加入 filter_opts
            if target_user_logins.any?
              filter_opts << OpenStruct.new(type: 'user_login', values: target_user_logins)
            else
              # 没有匹配的贡献者，返回空结果
              return {
                count: 0,
                total_page: 0,
                page: page,
                items: []
              }
            end
          end
          label_mapping = {
            'bug' => ['bug'],
            'feature' => ['feature', 'engineering', 'refactor'],
            'question' => ['question'],
            'other' => []
          }

          if params[:labelFilter].present?
            mapped_labels = label_mapping[params[:labelFilter]] || [params[:labelFilter]]
            if params[:labelFilter] == 'other'
              filter_opts << OpenStruct.new(
                type: 'labels',
                values: [],
                not_exists: true # 标记为不存在查询
              )

            else
              filter_opts << OpenStruct.new(type: 'labels', values: mapped_labels)
            end
          end

          resp = indexer.terms_by_repo_urls(
            repo_urls,
            begin_date,
            end_date,
            per: per,
            page: page,
            filter_opts: filter_opts,
            sort_opts: sort_opts
          )

          count = indexer.count_by_repo_urls(repo_urls, begin_date, end_date, filter_opts: filter_opts)

          ALLOWED_FIELDS = %w[
    repository
    id_in_repo
    url
    title
    state
    created_at
    closed_at
    time_to_close_days
    time_to_first_attention_without_bot
    labels
    user_login
    assignee_login
    num_of_comments_without_bot
    priority
  ].freeze

          hits = resp&.dig('hits', 'hits') || []

          # 获取贡献者信息（用于返回 organization 字段）
          user_logins = hits.map { |hit| hit.dig('_source', 'user_login') }.compact.uniq

          contributors_info = {}
          if user_logins.any?
            contrib_indexer, _, _ = select_idx_repos_by_lablel_and_level(
              label,
              level,
              GiteeContributorEnrich,
              GithubContributorEnrich,
              GitcodeContributorEnrich
            )

            contributors_list = contrib_indexer.fetch_contributors_list(
              repo_urls,
              begin_date,
              end_date,
              label: label,
              level: level
            )

            contributors_info = contributors_list.each_with_object({}) do |item, hash|
              login = item.respond_to?(:contributor) ? item.contributor : item['contributor']
              hash[login] = item if login
            end
          end

          items = hits.map do |hit|
            source = hit['_source'] || {}

            item_hash = ALLOWED_FIELDS.each_with_object({}) do |field, hash|
              hash[field] = source[field]
            end

            if item_hash['state'] == 'closed' && item_hash['time_to_first_attention_without_bot'].nil?
              item_hash['time_to_first_attention_without_bot'] = 0
            end

            # 嵌入贡献者信息
            user_login = item_hash['user_login']
            contributor = contributors_info[user_login]

            if contributor
              organization = contributor.respond_to?(:organization) ? contributor.organization : contributor['organization']
              is_internal = organization.to_s.downcase == 'huawei'

              item_hash['contributor'] = {
                'organization' => organization,
                'is_internal' => is_internal
              }
            else
              item_hash['contributor'] = {
                'organization' => nil,
                'is_internal' => false
              }
            end

            item_hash
          end

          {
            count: count,
            total_page: (count.to_f / per).ceil,
            page: page,
            items: items
          }
        end

        desc '获取 Issue 总览数据 (Overview): 统计与质量分析',
             tags: ['CompassService / compass服务']

        params do
          requires :label, type: String, desc: 'Repo 或 Project 的 label'
          optional :level, type: String, default: 'repo', desc: '级别: repo 或 community'
          optional :beginDate, type: String, desc: '开始日期 (ISO8601)'
          optional :endDate, type: String, desc: '结束日期 (ISO8601)'
          requires :identifier, type: String, desc: 'identifier'
          optional :ResponsiblePerson, type: Integer, desc: '责任人 user_id'
          optional :labelFilter, type: String, desc: '标签筛选'
          optional :priority, type: String, desc: '优先级筛选'
        end

        post :issues_overview do

          label = ShortenedLabel.normalize_label(params[:label])
          level = params[:level]
          begin_date = params[:beginDate]
          end_date = params[:endDate]
          user_id = params[:ResponsiblePerson]

          indexer, repo_urls = select_idx_repos_by_lablel_and_level(
            label,
            level,
            GiteeIssueEnrich,
            GithubIssueEnrich,
            GitcodeIssueEnrich
          )

          if user_id.present?
            dashboard = Dashboard.find_by!(identifier: params[:identifier])
            responsible_labels = DashboardCommunityResponsiblePerson
                                   .where(user_id: user_id)
                                   .where(dashboard_id: dashboard.id)
                                   .pluck(:label)

            repo_urls = repo_urls & responsible_labels if responsible_labels.present?
          end

          base_filter_opts = []
          base_filter_opts << OpenStruct.new(type: 'pull_request', values: ['false'])

          label_mapping = {
            'bug' => ['bug'],
            'feature' => ['feature', 'engineering', 'refactor'],
            'question' => ['question'],
            'other' => []
          }

          if params[:priority].present?
            base_filter_opts << OpenStruct.new(type: 'priority', values: params[:priority])
          end


          if params[:labelFilter].present?
            mapped_labels = label_mapping[params[:labelFilter]] || [params[:labelFilter]]
            if params[:labelFilter] == 'other'
              base_filter_opts << OpenStruct.new(
                type: 'labels',
                values: [],
                not_exists: true # 标记为不存在查询
              )

            else
              base_filter_opts << OpenStruct.new(type: 'labels', values: mapped_labels)
            end
          end

          # 新建 Issue 数量
          # 直接使用基础过滤器查询时间范围内的总数
          new_issue_count = indexer.count_by_repo_urls(
            repo_urls,
            begin_date,
            end_date,
            filter_opts: base_filter_opts
          )

          # Issue 解决百分比
          # 逻辑：(Closed Issue / New Issue) * 100
          # 需要在基础过滤器上叠加 state=closed
          closed_filter = base_filter_opts + [OpenStruct.new(type: 'state', values: ['closed'])]

          resolved_issue_count = indexer.count_by_repo_urls(
            repo_urls,
            begin_date,
            end_date,
            filter_opts: closed_filter
          )

          resolution_percentage = 0
          if new_issue_count > 0
            resolution_percentage = (resolved_issue_count.to_f / new_issue_count * 100).round(2)
          end

          # 未响应 Issue 数量
          # 逻辑：state=open 且 评论数=0
          unresponsive_filter = base_filter_opts + [
            OpenStruct.new(type: 'state', values: ['open']),
            OpenStruct.new(
              query_type: :should,
              conditions: [
                { term: { 'num_of_comments_without_bot' => 0 } },
                { bool: { must_not: { exists: { field: 'num_of_comments_without_bot' } } } }
              ]
            )
          ]

          unresponsive_issue_count = indexer.count_should_by_repo_urls(
            repo_urls,
            begin_date,
            end_date,
            filter_opts: unresponsive_filter
          )

          # 平均响应时间：与 count 同属时间范围与 filter，对 time_to_first_attention_without_bot 做 avg（单位与天数字段一致）
          avg_response_time = nil
          begin
            val = indexer
                    .base_terms_by_repo_urls(
                      repo_urls, begin_date, end_date,
                      filter_opts: base_filter_opts
                    )
                    .per(0)
                    .aggregate(
                      { issue_avg_first_attention: { avg: { field: 'time_to_first_attention_without_bot' } } }
                    )
                    .execute
                    .aggregations
                    .dig('issue_avg_first_attention', 'value')
            avg_response_time = val.present? ? val.round(2) : nil
          rescue => e
            Rails.logger.error "issues_overview avg_response_time: #{e.message}"
          end

          # 返回结果
          {
            new_issue_count: new_issue_count,
            issue_resolution_percentage: "#{resolution_percentage}%",

            issue_resolution_numerator: resolved_issue_count,
            issue_resolution_denominator: new_issue_count,
            avg_response_time: avg_response_time,
            unresponsive_issue_count: unresponsive_issue_count
          }
        end

        desc '更新 Issue 优先级',
             tags: ['CompassService / compass服务'],
             hidden: true

        params do
          requires :label, type: String, desc: 'Repo 或 Project 的 label'
          requires :url, type: String, desc: 'Issue url'
          requires :priority, type: String, values: ['fatal', 'serious', 'medium', 'info'], desc: '优先级:  致命, 严重, 一般, 提示'
          requires :identifier, type: String, desc: 'identifier'

        end

        post :update_issue_priority do
          label = ShortenedLabel.normalize_label(params[:label])
          issue_url = params[:url]
          priority = params[:priority]

          dashboard = Dashboard.find_by!(identifier: params[:identifier])


          require_dashboard_editor!(dashboard)


          indexer, repo_urls = select_idx_repos_by_lablel_and_level(
            label,
            'repo',
            GiteeIssueEnrich,
            GithubIssueEnrich,
            GitcodeIssueEnrich
          )

          resp = indexer.must(term: { 'url' => issue_url }).execute.raw_response
          issues = resp&.dig('hits', 'hits') || []
          error!({ error: 'Issue 不存在' }, 404) if issues.empty?

          # 更新优先级到 OpenSearch
          begin
            issue = issues.first
            issue_source = issue['_source']
            issue_id_es = issue['_id']

            # 使用 SearchFlip 的 bulk 方法更新文档
            indexer.bulk do |bulk|
              bulk.update issue_id_es, doc: { priority: priority }
            end

            {
              status: 'success',
              message: '优先级更新成功',
              data: {
                issue_id: issue_url,
                priority: priority,
                repository: issue_source['repository']
              }
            }
          rescue => e
            error!({ error: "更新失败: #{e.message}" }, 500)
          end
        end

        desc '获取总览数据 (Overview): PR统计与代码提交统计',
             tags: ['CompassService / compass服务']

        params do
          requires :label, type: String, desc: 'Repo 或 Project 的 label'
          optional :level, type: String, default: 'repo', desc: '级别: repo 或 community'
          optional :beginDate, type: String, desc: '开始日期 (ISO8601)'
          optional :endDate, type: String, desc: '结束日期 (ISO8601)'
        end

        post :pulls_overview do

          label = ShortenedLabel.normalize_label(params[:label])
          level = params[:level]
          begin_date = params[:beginDate]
          end_date = params[:endDate]

          pull_indexer, repo_urls = select_idx_repos_by_lablel_and_level(
            label, level, GiteePullEnrich, GithubPullEnrich, GitcodePullEnrich
          )

          new_pr_count = pull_indexer.count_by_repo_urls(repo_urls, begin_date, end_date)

          closed_filter = [OpenStruct.new(type: 'state', values: ['closed', 'merged'])]

          resolved_pr_count = pull_indexer.count_by_repo_urls(
            repo_urls, begin_date, end_date, filter_opts: closed_filter
          )

          resolution_percentage = 0
          if new_pr_count > 0
            resolution_percentage = (resolved_pr_count.to_f / new_pr_count * 100).round(2)
          end

          unresponsive_filter = [
            OpenStruct.new(type: 'state', values: ['open']),
            OpenStruct.new(type: 'num_review_comments_without_bot', values: [0]) # 代码 Review 评论数为 0
          ]

          unresponsive_pr_count = pull_indexer.count_by_repo_urls(
            repo_urls, begin_date, end_date, filter_opts: unresponsive_filter
          )

          commit_indexer, _ = select_idx_repos_by_lablel_and_level(
            label, level, GiteeGitEnrich, GithubGitEnrich, GitcodeGitEnrich
          )

          commit_repo_urls = repo_urls.map { |url| "#{url}.git" }
          commit_count = commit_indexer.count_by_repo_urls(commit_repo_urls, begin_date, end_date, filter: :grimoire_creation_date)

          {
            new_pr_count: new_pr_count, # 新建 PR 数量
            pr_resolution_percentage: "#{resolution_percentage}%", # PR 解决百分比
            unresponsive_pr_count: unresponsive_pr_count, # 未响应 PR 数量
            commit_count: commit_count, # 代码提交数量

          }
        end

        desc '获取 PR (Pull Request) 详情列表',
             tags: ['CompassService / compass服务']

        params do
          requires :label, type: String, desc: 'Repo 或 Project 的 label'
          optional :level, type: String, default: 'repo', desc: '级别: repo 或 community'
          optional :page, type: Integer, default: 1, desc: '页码'
          optional :per, type: Integer, default: 9, desc: '每页数量'
          optional :beginDate, type: String, desc: '开始日期 (ISO8601)'
          optional :endDate, type: String, desc: '结束日期 (ISO8601)'

          # 筛选参数
          optional :filter_opts, type: Array do
            optional :type, type: String
            optional :values, type: Array[String]
          end

          # 排序参数
          optional :sort_opts, type: Array do
            optional :key, type: String
            optional :direction, type: String
          end
        end

  #       post :pulls_detail_list do
  #
  #         label = ShortenedLabel.normalize_label(params[:label])
  #         level = params[:level]
  #         page = params[:page]
  #         per = params[:per]
  #         begin_date = params[:beginDate]
  #         end_date = params[:endDate]
  #
  #         filter_opts = (params[:filterOpts] || []).map { |opt| OpenStruct.new(opt) }
  #         sort_opts = if params[:sortOpts].nil? || params[:sortOpts].empty?
  #                       [OpenStruct.new(type: 'created_at', direction: 'desc')]
  #                     else
  #                       raw_opts = [params[:sortOpts]].flatten.compact
  #                       parsed_opts = raw_opts.map { |opt| OpenStruct.new(opt) }
  #                       has_created_at = parsed_opts.any? { |opt| opt.type == 'created_at' }
  #                       unless has_created_at
  #                         parsed_opts << OpenStruct.new(type: 'created_at', direction: 'desc')
  #                       end
  #
  #                       parsed_opts
  #                     end
  #
  #         indexer, repo_urls = select_idx_repos_by_lablel_and_level(
  #           label,
  #           level,
  #           GiteePullEnrich,
  #           GithubPullEnrich,
  #           GitcodePullEnrich
  #         )
  #
  #
  #         org_filter_opt = filter_opts.find { |opt| opt.type == 'organization' }
  #         filter_opts.delete_if { |opt| opt.type == 'organization' }
  #
  #         target_orgs = org_filter_opt&.values || []
  #         resp = indexer.terms_by_repo_urls(
  #           repo_urls,
  #           begin_date,
  #           end_date,
  #           per: per,
  #           page: page,
  #           filter_opts: filter_opts,
  #           sort_opts: sort_opts
  #         )
  #
  #         count = indexer.count_by_repo_urls(
  #           repo_urls,
  #           begin_date,
  #           end_date,
  #           filter_opts: filter_opts
  #         )
  #
  #         hits = resp&.dig('hits', 'hits') || []
  #
  #         # 提取所有唯一的 user_login
  #         user_logins = hits.map { |hit| hit.dig('_source', 'user_login') }.compact.uniq
  #
  #         # 获取贡献者信息
  #         contrib_indexer, repo_urls = select_idx_repos_by_lablel_and_level(
  #           label,
  #           level,
  #           GiteeContributorEnrich,
  #           GithubContributorEnrich,
  #           GitcodeContributorEnrich
  #         )
  #
  #         contributors_info = {}
  #         if user_logins.any?
  #
  #           contributors_list = contrib_indexer.fetch_contributors_list(repo_urls, begin_date, end_date, label: label, level: level)
  #
  #           # 构建 user_login -> 贡献者信息的映射
  #           contributors_info = contributors_list.each_with_object({}) do |item, hash|
  #             login = item.respond_to?(:contributor) ? item.contributor : item['contributor']
  #             hash[login] = item if login
  #           end
  #         end
  #
  #         ALLOWED_FIELDS = %w[
  #             closed_at
  #             created_at
  #             id_in_repo
  #             labels
  #             merge_author_login
  #             num_review_comments
  #             repository
  #             reviewers_login
  #             state
  #             time_to_close_days
  #             time_to_first_attention_without_bot
  #             title
  #             url
  #             user_login
  # ].freeze
  #
  #         items = hits.map do |hit|
  #           source = hit['_source'] || {}
  #
  #           item_hash = ALLOWED_FIELDS.each_with_object({}) do |field, hash|
  #             hash[field] = source[field]
  #           end
  #
  #           if item_hash['state'] == 'closed' && item_hash['time_to_first_attention_without_bot'].nil?
  #             item_hash['time_to_first_attention_without_bot'] = 0
  #           end
  #
  #           # 嵌入贡献者信息 ==========
  #           user_login = item_hash['user_login']
  #           contributor = contributors_info[user_login]
  #
  #           if contributor
  #             # 提取组织信息
  #             organization = contributor.respond_to?(:organization) ? contributor.organization : contributor['organization']
  #
  #             # 判断内外部标签
  #             is_internal = organization.to_s.downcase == 'huawei'
  #
  #             item_hash['contributor'] = {
  #               'organization' => organization,
  #               'is_internal' => is_internal
  #             }
  #           else
  #             # 如果找不到贡献者信息，设置默认值
  #             item_hash['contributor'] = {
  #               'organization' => nil,
  #               'is_internal' => false
  #             }
  #           end
  #
  #           item_hash
  #         end
  #
  #         if target_orgs.present?
  #           target_orgs_lower = target_orgs.map(&:to_s).map(&:downcase)
  #           items = items.select do |item|
  #             contributor = item['contributor']
  #             org = contributor&.dig('organization')
  #             target_orgs_lower.include?(org)
  #           end
  #
  #           # 重新计算分页
  #           count = items.length
  #           total_page = (count.to_f / per).ceil
  #           page = [page, total_page].min
  #           page = 1 if page < 1
  #           start_idx = (page - 1) * per
  #           items = items[start_idx, per] || []
  #         end
  #
  #         {
  #           count: count,
  #           total_page: (count.to_f / per).ceil,
  #           page: page,
  #           items: items
  #         }
  #       end
        post :pulls_detail_list do
          label = ShortenedLabel.normalize_label(params[:label])
          level = params[:level]
          page = params[:page]
          per = params[:per]
          begin_date = params[:beginDate]
          end_date = params[:endDate]

          filter_opts = (params[:filterOpts] || []).map { |opt| OpenStruct.new(opt) }
          sort_opts = if params[:sortOpts].nil? || params[:sortOpts].empty?
                        [OpenStruct.new(type: 'created_at', direction: 'desc')]
                      else
                        raw_opts = [params[:sortOpts]].flatten.compact
                        parsed_opts = raw_opts.map { |opt| OpenStruct.new(opt) }
                        has_created_at = parsed_opts.any? { |opt| opt.type == 'created_at' }
                        unless has_created_at
                          parsed_opts << OpenStruct.new(type: 'created_at', direction: 'desc')
                        end
                        parsed_opts
                      end

          indexer, repo_urls = select_idx_repos_by_lablel_and_level(
            label,
            level,
            GiteePullEnrich,
            GithubPullEnrich,
            GitcodePullEnrich
          )

          # 提取组织筛选条件
          org_filter_opt = filter_opts.find { |opt| opt.type == 'organization' }
          filter_opts.delete_if { |opt| opt.type == 'organization' }
          target_orgs = org_filter_opt&.values || []

          # ========== 如果有组织筛选，先获取贡献者信息 ==========
          if target_orgs.present?
            contrib_indexer, _, _ = select_idx_repos_by_lablel_and_level(
              label,
              level,
              GiteeContributorEnrich,
              GithubContributorEnrich,
              GitcodeContributorEnrich
            )

            # 获取所有贡献者（不带分页，获取全部）
            all_contributors = contrib_indexer.fetch_contributors_list(
              repo_urls,
              begin_date,
              end_date,
              label: label,
              level: level
            )

            # 筛选目标组织的贡献者
            target_orgs_lower = target_orgs.map(&:to_s).map(&:downcase)

            target_user_logins = all_contributors
                                   .select do |item|
              org = item.respond_to?(:organization) ? item.organization : item['organization']
              target_orgs_lower.include?(org.to_s.downcase)
            end
                                   .map { |item| item.respond_to?(:contributor) ? item.contributor : item['contributor'] }
                                   .compact
                                   .uniq

            # 将 user_login 筛选条件加入 filter_opts
            if target_user_logins.any?
              filter_opts << OpenStruct.new(type: 'user_login', values: target_user_logins)
            else
              # 没有匹配的贡献者，返回空结果
              return {
                count: 0,
                total_page: 0,
                page: page,
                items: []
              }
            end
          end
          # ========== 组织筛选处理结束 ==========

          resp = indexer.terms_by_repo_urls(
            repo_urls,
            begin_date,
            end_date,
            per: per,
            page: page,
            filter_opts: filter_opts,
            sort_opts: sort_opts
          )

          count = indexer.count_by_repo_urls(
            repo_urls,
            begin_date,
            end_date,
            filter_opts: filter_opts
          )

          hits = resp&.dig('hits', 'hits') || []

          # 提取所有唯一的 user_login
          user_logins = hits.map { |hit| hit.dig('_source', 'user_login') }.compact.uniq

          # 获取贡献者信息
          contributors_info = {}
          if user_logins.any?
            contrib_indexer, _, _ = select_idx_repos_by_lablel_and_level(
              label,
              level,
              GiteeContributorEnrich,
              GithubContributorEnrich,
              GitcodeContributorEnrich
            )

            contributors_list = contrib_indexer.fetch_contributors_list(
              repo_urls,
              begin_date,
              end_date,
              label: label,
              level: level
            )

            # 构建 user_login -> 贡献者信息的映射
            contributors_info = contributors_list.each_with_object({}) do |item, hash|
              login = item.respond_to?(:contributor) ? item.contributor : item['contributor']
              hash[login] = item if login
            end
          end

          allowed_fields = %w[
                  closed_at
                  created_at
                  id_in_repo
                  labels
                  merge_author_login
                  num_review_comments
                  repository
                  reviewers_login
                  state
                  time_to_close_days
                  time_to_first_attention_without_bot
                  title
                  url
                  user_login
                ].freeze

          items = hits.map do |hit|
            source = hit['_source'] || {}

            item_hash = allowed_fields.each_with_object({}) do |field, hash|
              hash[field] = source[field]
            end

            if item_hash['state'] == 'closed' && item_hash['time_to_first_attention_without_bot'].nil?
              item_hash['time_to_first_attention_without_bot'] = 0
            end

            # 嵌入贡献者信息 ==========
            user_login = item_hash['user_login']
            contributor = contributors_info[user_login]

            if contributor
              # 提取组织信息
              organization = contributor.respond_to?(:organization) ? contributor.organization : contributor['organization']

              # 判断内外部标签
              is_internal = organization.to_s.downcase == 'huawei'

              item_hash['contributor'] = {
                'organization' => organization,
                'is_internal' => is_internal
              }
            else
              # 如果找不到贡献者信息，设置默认值
              item_hash['contributor'] = {
                'organization' => nil,
                'is_internal' => false
              }
            end

            item_hash
          end

          {
            count: count,
            total_page: (count.to_f / per).ceil,
            page: page,
            items: items
          }
        end

        desc '获取社区仓库列表',
             tags: ['CompassService / compass服务']

        params do
          requires :label, type: String, desc: 'Repo 或 Project 的 label'
          optional :level, type: String, default: 'repo', desc: '级别: repo 或 community'

        end

        post :repository_list do
          label = ShortenedLabel.normalize_label(params[:label])
          level = params[:level]
          indexer, repo_urls = select_idx_repos_by_lablel_and_level(
            label,
            level,
            GiteePullEnrich,
            GithubPullEnrich,
            GitcodePullEnrich
          )

          {
            items: repo_urls.sort_by { |url| url.to_s.downcase }
          }

          end

        desc '获取社区 Issue 汇总列表（按仓库分组）',
             tags: ['CompassService / compass服务']

        params do
          requires :label, type: String, desc: '社区或仓库 label'
          optional :level, type: String, default: 'community', desc: '级别: community 或 repo'
          optional :page, type: Integer, default: 1, desc: '页码'
          optional :per, type: Integer, default: 20, desc: '每页数量'
          optional :beginDate, type: String, desc: '开始日期  '
          optional :endDate, type: String, desc: '结束日期 '
          optional :ResponsiblePerson, type: Integer, desc: '责任人 user_id'
          optional :identifier, type: String, desc: 'identifier'
          # 筛选参数
          optional :filterOpts, type: Array do
            optional :type, type: String
            optional :values, type: Array[String]
          end

          # 排序参数
          optional :sortOpts, type: Hash do
            optional :type, type: String
            optional :direction, type: String
          end
        end
        post :community_issue_summary_list do
          label = ShortenedLabel.normalize_label(params[:label])
          level = params[:level]
          begin_date = params[:beginDate]
          end_date = params[:endDate]
          user_id = params[:ResponsiblePerson]
          page = [params[:page].to_i, 1].max
          per = [params[:per].to_i, 1].max


          filter_opts = (params[:filterOpts] || []).map { |opt| OpenStruct.new(opt) }
          sort_opts = params[:sortOpts]

          indexer, repo_urls = select_idx_repos_by_lablel_and_level(
            label,
            level,
            GiteeIssueEnrich,
            GithubIssueEnrich,
            GitcodeIssueEnrich
          )


          dashboard = Dashboard.find_by!(identifier: params[:identifier])
          if user_id.present?
            dashboard = Dashboard.find_by!(identifier: params[:identifier])
            responsible_labels = DashboardCommunityResponsiblePerson
                                   .where(user_id: user_id)
                                   .where(dashboard_id: dashboard.id)
                                   .pluck(:label)

            repo_urls = repo_urls & responsible_labels
          end

          persons = dashboard.dashboard_community_responsible_people.includes(:user)

          repo_to_persons = persons.group_by(&:label).transform_values do |person_list|
            person_list.map do |person|
              user = person.user
              {
                user_id: person.user_id,
                user_name: user&.name,
                user_email: user&.email
              }
            end
          end
          filter_opts << OpenStruct.new(type: 'pull_request', values: ['false'])

          total_issue_count = indexer.count_by_repo_urls(
            repo_urls,
            begin_date,
            end_date,
            filter_opts: filter_opts
          )

          batch_size = 1000
          total_fetch_pages = (total_issue_count.to_f / batch_size).ceil
          grouped = Hash.new do |h, k|
            h[k] = {
              issue_total_count: 0,
              issue_open_count: 0,
              issue_closed_count: 0,
              close_time_sum: 0.0,
              close_time_count: 0,
              first_response_sum: 0.0,
              first_response_count: 0,
              open_unresponsive_count: 0
            }
          end

          1.upto(total_fetch_pages) do |fetch_page|
            resp = indexer.terms_by_repo_urls(
              repo_urls,
              begin_date,
              end_date,
              per: batch_size,
              page: fetch_page,
              filter_opts: filter_opts,
              sort_opts: []
            )

            hits = resp&.dig('hits', 'hits') || []
            break if hits.empty?

            hits.each do |hit|
              source = hit['_source'] || {}
              repo = source['repository'].presence || source['tag'].presence || 'unknown'
              state = source['state'].to_s.downcase
              comments_without_bot = source['num_of_comments_without_bot'].to_i

              row = grouped[repo]
              row[:issue_total_count] += 1
              row[:issue_open_count] += 1 if state == 'open'
              row[:issue_closed_count] += 1 if state == 'closed'

              close_time = source['time_to_close_days']
              if !close_time.nil?
                row[:close_time_sum] += close_time.to_f
                row[:close_time_count] += 1
              end

              first_response_time = source['time_to_first_attention']
              if !first_response_time.nil?
                row[:first_response_sum] += first_response_time.to_f
                row[:first_response_count] += 1
              end

              if state == 'open' && comments_without_bot == 0
                row[:open_unresponsive_count] += 1
              end
            end
          end

          repo_url_to_identifier =
            Dashboard.all.each_with_object({}) do |d, h|
              # 先解析 JSON 字符串为数组
              urls = JSON.parse(d.repo_urls) rescue []

              first_url = urls.first.to_s.strip
              next if first_url.blank?

              h[first_url] = d.identifier
            end

          items = grouped.map do |repo, stat|
            issue_total = stat[:issue_total_count]
            closed_loop_rate = issue_total.positive? ? (stat[:issue_closed_count].to_f / issue_total * 100).round(2) : 0.0
            avg_close_time = stat[:close_time_count].positive? ? (stat[:close_time_sum] / stat[:close_time_count]).round(2) : nil
            avg_first_response = stat[:first_response_count].positive? ? (stat[:first_response_sum] / stat[:first_response_count]).round(2) : nil

            {
              identifier: repo_url_to_identifier[repo.to_s],
              repo_url: repo,
              issue_total_count: issue_total,
              issue_open_count: stat[:issue_open_count],
              closed_loop_rate: closed_loop_rate,
              avg_closed_loop_time: avg_close_time,
              avg_first_response_time: avg_first_response,
              open_unresponsive_count: stat[:open_unresponsive_count],
              responsible_person: repo_to_persons[repo.to_s] || []
            }
          end.sort_by { |row| -row[:issue_total_count] }

          sort_key_map = {
            'issue_total_count' => :issue_total_count,
            'issue_open_count' => :issue_open_count,
            'closed_loop_rate' => :closed_loop_rate,
            'avg_closed_loop_time' => :avg_closed_loop_time,
            'avg_first_response_time' => :avg_first_response_time,
            'open_unresponsive_count' => :open_unresponsive_count
          }
          sort_opts = {} unless sort_opts.is_a?(Hash)
          sort_key = sort_key_map[sort_opts&.dig(:type).to_s] || :issue_total_count
          sort_direction = sort_opts&.dig(:direction).to_s.downcase == 'asc' ? :asc : :desc

          items = items.sort do |a, b|
            av = a[sort_key]
            bv = b[sort_key]

            if av.nil? && bv.nil?
              0
            elsif av.nil?
              1
            elsif bv.nil?
              -1
            else
              cmp = av.is_a?(String) && bv.is_a?(String) ? (av <=> bv) : (av.to_f <=> bv.to_f)
              sort_direction == :desc ? -cmp : cmp
            end
          end

          total_repo_count = items.size
          paged_items = items[((page - 1) * per), per] || []

          {
            count: total_repo_count,
            total_page: (total_repo_count.to_f / per).ceil,
            page: page,
            items: paged_items
          }
        end

        desc '获取社区 pull 汇总列表（按仓库分组）',
             tags: ['CompassService / compass服务']

        params do
          requires :label, type: String, desc: '社区或仓库 label'
          optional :level, type: String, default: 'community', desc: '级别: community 或 repo'
          optional :page, type: Integer, default: 1, desc: '页码'
          optional :per, type: Integer, default: 20, desc: '每页数量'
          optional :beginDate, type: String, desc: '开始日期  '
          optional :endDate, type: String, desc: '结束日期 '
          # 筛选参数
          optional :filterOpts, type: Array do
            optional :type, type: String
            optional :values, type: Array[String]
          end

          # 排序参数
          optional :sortOpts, type: Hash do
            optional :key, type: String
            optional :direction, type: String
          end
        end
        post :community_pull_summary_list do
          label = ShortenedLabel.normalize_label(params[:label])
          level = params[:level]
          begin_date = params[:beginDate]
          end_date = params[:endDate]
          page = [params[:page].to_i, 1].max
          per = [params[:per].to_i, 1].max

          filter_opts = (params[:filterOpts] || []).map { |opt| OpenStruct.new(opt) }
          sort_opts = params[:sortOpts]

          indexer, repo_urls = select_idx_repos_by_lablel_and_level(
            label,
            level,
            GiteePullEnrich,
            GithubPullEnrich,
            GitcodePullEnrich
          )

          total_pull_count = indexer.count_by_repo_urls(
            repo_urls,
            begin_date,
            end_date,
            filter_opts: filter_opts
          )

          batch_size = 1000
          total_fetch_pages = (total_pull_count.to_f / batch_size).ceil
          grouped = Hash.new do |h, k|
            h[k] = {
              pull_total_count: 0,
              pull_open_count: 0,
              pull_closed_count: 0,
              close_time_sum: 0.0,
              close_time_count: 0,
              first_response_sum: 0.0,
              first_response_count: 0,
              open_unresponsive_count: 0
            }
          end

          1.upto(total_fetch_pages) do |fetch_page|
            resp = indexer.terms_by_repo_urls(
              repo_urls,
              begin_date,
              end_date,
              per: batch_size,
              page: fetch_page,
              filter_opts: filter_opts,
              sort_opts: []
            )

            hits = resp&.dig('hits', 'hits') || []
            break if hits.empty?

            hits.each do |hit|
              source = hit['_source'] || {}
              repo = source['repository'].presence || source['tag'].presence || 'unknown'
              state = source['state'].to_s.downcase
              comments_without_bot = source['num_of_comments_without_bot'].to_i

              row = grouped[repo]
              row[:pull_total_count] += 1
              row[:pull_open_count] += 1 if state == 'open'
              row[:pull_closed_count] += 1 if state == 'closed'

              close_time = source['time_to_close_days']
              if !close_time.nil?
                row[:close_time_sum] += close_time.to_f
                row[:close_time_count] += 1
              end

              first_response_time = source['time_to_first_attention_without_bot']
              if !first_response_time.nil?
                row[:first_response_sum] += first_response_time.to_f
                row[:first_response_count] += 1
              end

              if state == 'open' && comments_without_bot == 0
                row[:open_unresponsive_count] += 1
              end
            end
          end

          repo_url_to_identifier =
            Dashboard.all.each_with_object({}) do |d, h|
              # 先解析 JSON 字符串为数组
              urls = JSON.parse(d.repo_urls) rescue []

              first_url = urls.first.to_s.strip
              next if first_url.blank?

              h[first_url] = d.identifier
            end
          items = grouped.map do |repo, stat|
            pull_total = stat[:pull_total_count]
            closed_loop_rate = pull_total.positive? ? (stat[:pull_closed_count].to_f / pull_total * 100).round(2) : 0.0
            avg_close_time = stat[:close_time_count].positive? ? (stat[:close_time_sum] / stat[:close_time_count]).round(2) : nil
            avg_first_response = stat[:first_response_count].positive? ? (stat[:first_response_sum] / stat[:first_response_count]).round(2) : nil

            {
              identifier: repo_url_to_identifier[repo.to_s],
              repo_url: repo,
              pull_total_count: pull_total,
              pull_open_count: stat[:pull_open_count],
              closed_loop_rate: closed_loop_rate,
              avg_closed_loop_time: avg_close_time,
              avg_first_response_time: avg_first_response,
              open_unresponsive_count: stat[:open_unresponsive_count]
            }
          end.sort_by { |row| -row[:pull_total_count] }

          sort_key_map = {
            'pull_total_count' => :pull_total_count,
            'pull_open_count' => :pull_open_count,
            'closed_loop_rate' => :closed_loop_rate,
            'avg_closed_loop_time' => :avg_closed_loop_time,
            'avg_first_response_time' => :avg_first_response_time,
            'open_unresponsive_count' => :open_unresponsive_count
          }
          sort_key = sort_key_map[sort_opts&.dig(:type).to_s] || :pull_total_count
          sort_direction = sort_opts&.dig(:direction).to_s.downcase == 'asc' ? :asc : :desc

          items = items.sort do |a, b|
            av = a[sort_key]
            bv = b[sort_key]

            if av.nil? && bv.nil?
              0
            elsif av.nil?
              1
            elsif bv.nil?
              -1
            else
              cmp = av.is_a?(String) && bv.is_a?(String) ? (av <=> bv) : (av.to_f <=> bv.to_f)
              sort_direction == :desc ? -cmp : cmp
            end
          end

          total_repo_count = items.size
          paged_items = items[((page - 1) * per), per] || []

          {
            count: total_repo_count,
            total_page: (total_repo_count.to_f / per).ceil,
            page: page,
            items: paged_items
          }
        end



        desc '创建/设置/删除责任人',
             tags: ['CompassService / Compass服务'],
             hidden: true

        params do
          requires :identifier, type: String, desc: '看板唯一编码'
          requires :repo_url, type: String, desc: '仓库地址'
          optional :ResponsiblePerson, type: Integer, desc: '责任人用户ID。如果不传或传空，则表示移除该仓库的责任人'
        end

        post :set_responsible_person do
          dashboard = Dashboard.find_by!(identifier: params[:identifier])

          require_dashboard_editor!(dashboard)

          user_id = params[:ResponsiblePerson]
          label = params[:repo_url]

          # 查找该仓库是否已有责任人
          existing = DashboardCommunityResponsiblePerson.find_by(
            dashboard_id: dashboard.id,
            label: label
          )

          if user_id.blank?
            if existing
              existing.destroy!
              { status: 'success', message: '责任人已移除' }
            else
              { status: 'success', message: '该仓库暂无责任人，无需移除' }
            end
          else
            # 执行原来的创建/更新逻辑
            # 检查用户是否存在
            user = User.find_by(id: user_id)
            error!({ error: '用户不存在' }, 404) unless user

            if existing
              # 更新为新的责任人
              existing.update!(
                user_id: user_id,
                updated_at: Time.current
              )
              { status: 'success', message: '责任人已更新' }
            else
              # 创建新的责任人记录
              DashboardCommunityResponsiblePerson.create!(
                dashboard_id: dashboard.id,
                user_id: user_id,
                label: label
              )
              { status: 'success', message: '责任人设置成功' }
            end
          end

        rescue ActiveRecord::RecordNotFound
          error!({ error: '看板不存在' }, 404)
        rescue ActiveRecord::RecordInvalid => e
          error!({ error: e.message }, 422)
        end



        desc '修改组织信息',
             tags: ['ContributorService / 贡献者服务']

        params do
          requires :contributor, type: String, desc: '贡献者用户名'
          requires :platform, type: String, desc: '平台类型 (gitee/github/gitcode)'
          requires :label, type: String, desc: '仓库或社区标签'
          optional :level, type: String, default: 'repo', desc: '级别: repo 或 community'

          # 组织信息数组
          requires :organization, type: Hash do
            requires :org_name, type: String, desc: '组织名称'
            requires :first_date, type: String, desc: '开始日期 (ISO8601)'
            optional :last_date, type: String, desc: '结束日期 (ISO8601)'
          end
        end

        post :manage_user_orgs do

          contributor = params[:contributor]
          platform = params[:platform]
          label = ShortenedLabel.normalize_label(params[:label])
          level = params[:level]
          organizations = [params[:organization]]

          # dashboard = Dashboard.includes(:dashboard_models, :dashboard_metrics)
          #                      .find_by!(identifier: params[:identifier])
          #
          # require_dashboard_editor!(dashboard)
          has_edit_permission = DashboardMember.where(user: current_user, status: :active).exists?(['role >= ?', 1])
          error!({ error: '需要编辑权限' }, 403) unless has_edit_permission

          current_user.id
          begin
            uuid = generate_uuid(contributor, ContributorOrg::SystemAdmin, label, level, platform)

            record = OpenStruct.new(
              id: uuid,
              uuid: uuid,
              contributor: contributor,
              org_change_date_list: organizations,
              modify_by: current_user.id,
              modify_type: ContributorOrg::SystemAdmin,
              platform_type: platform,
              is_bot: false,
              label: label,
              level: level,
              update_at_date: Time.current
            )

            ContributorOrg.import(record)

            clear_all_contributors_cache([label])

            { status: true, message: 'Organization updated successfully'}

          rescue => ex
            error!({ status: false, message: ex.message }, 422)
          end
        end

        desc '获取全部组织列表',
             tags: ['ContributorService / 贡献者服务']

        params do
          requires :label, type: String, desc: 'Repo 或 Project 的 label'
          optional :level, type: String, default: 'repo', desc: '级别: repo 或 community'
          requires :beginDate, type: String, desc: '开始日期 (ISO8601)'
          requires :endDate, type: String, desc: '结束日期 (ISO8601)'
        end

        post :organization_list do
          label = ShortenedLabel.normalize_label(params[:label])
          level = params[:level]
          begin_date = params[:beginDate]
          end_date = params[:endDate]


          indexer, repo_urls, origin = select_idx_repos_by_lablel_and_level(
            label,
            level,
            GiteeContributorEnrich,
            GithubContributorEnrich,
            GitcodeContributorEnrich
          )

          # 获取所有贡献者列表
          contributors_list = indexer.fetch_contributors_list(
            repo_urls,
            begin_date,
            end_date,
            label: label,
            level: level
          )

          # 提取所有唯一的组织（忽略空值，忽略大小写去重）
          # 保留原始大小写，但去重时忽略大小写
          organizations = contributors_list
                            .map { |item| item.respond_to?(:organization) ? item.organization : item['organization'] }
                            .compact
                            .map(&:to_s)
                            .map(&:strip)
                            .reject(&:blank?)
                            .group_by(&:downcase)  # 按小写分组
                            .map { |_, group| group.first }  # 取每组的第一个（保留原始大小写）
                            .sort
          {
            count: organizations.length,
            organizations: organizations
          }
        end


        desc '批量分配/邀请成员到看板',
             tags: ['CompassService / Compass服务'],
             hidden: true

        params do
          requires :identifier, type: String, desc: '看板唯一编码'

          requires :members, type: Array, desc: '成员列表' do
            requires :user_id, type: Integer, desc: '被分配用户ID'
            optional :role, type: Integer, default: 0, desc: '角色权限0：查看 1: 编辑 2 管理员'
            optional :remark, type: String, desc: '备注说明'
          end
        end

        post :assign_members do
          dashboard = Dashboard.find_by!(identifier: params[:identifier])

          # 需要管理员权限才能分配成员
          require_dashboard_editor!(dashboard)

          members_params = params[:members]
          results = { success: [], failed: [], skipped: [] }

          # 事务处理，确保数据一致性
          DashboardMember.transaction do
            members_params.each do |member_param|
              user_id = member_param[:user_id]
              role = member_param[:role] || 0
              remark = member_param[:remark]

              # 跳过自己
              if user_id == current_user.id
                results[:skipped] << { user_id: user_id, reason: '不能为自己分配角色' }
                next
              end

              # 检查用户是否已存在
              existing_member = dashboard.dashboard_members.find_by(user_id: user_id)
              if existing_member
                results[:skipped] << { user_id: user_id, reason: '该用户已是看板成员' }
                next
              end

              # 检查用户是否存在
              user = User.find_by(id: user_id)
              unless user
                results[:failed] << { user_id: user_id, reason: '用户不存在' }
                next
              end

              member = dashboard.dashboard_members.new(
                user_id: user_id,
                role: role,
                status: :active,
                invited_by: current_user,
                joined_at: Time.current,
                remark: remark
              )

              if member.save
                results[:success] << {
                  id: member.id,
                  user_id: user_id,
                  user_name: user.name,
                  role: role
                }
              else
                results[:failed] << {
                  user_id: user_id,
                  reason: member.errors.full_messages.join(', ')
                }
              end
            end
          end

          # 根据结果返回不同状态码
          if results[:success].any?
            status_code = results[:failed].any? || results[:skipped].any? ? 207 : 200
            present({
                      status: 'partial_success',
                      message: "成功添加 #{results[:success].length} 人，失败 #{results[:failed].length} 人，跳过 #{results[:skipped].length} 人",
                      data: results
                    })
          else
            error!({
                     status: 'failed',
                     message: '所有成员添加失败',
                     data: results
                   }, 422)
          end

        rescue ActiveRecord::RecordNotFound
          error!({ error: '看板不存在' }, 404)
        end



        desc '模糊查询用户', hidden: true, tags: ['admin'], success: {
          code: 201
        }, detail: '模糊查询用户'
        params do
          requires :keyword, type: String, desc: 'keyword', documentation: { param_type: 'body', example: 'Nae' }
          optional :page, type: Integer, default: 1
          optional :per_page, type: Integer, default: 20
        end
        post :search_user do
          page = params[:page]
          per_page = params[:per_page]
          keywords = params[:keyword]


          users = if keywords.present?
                    User.where('name LIKE :kw OR email LIKE :kw', kw: "%#{keywords}%")
                  else
                    User.none  # 或者 User.where(id: nil) 返回空关系
                  end


          total = users.size
          paged_users = users.offset((page - 1) * per_page).limit(per_page)

          result = paged_users.map do |user|
            {
              id: user.id,
              name: user.name,
              email: user.email,
            }
          end

          {
            total:,
            page:,
            per_page:,
            data: result
          }
        end

        desc '获取看板有权限用户列表',
             tags: ['CompassService / Compass服务'],
             hidden: true

        params do
          requires :identifier, type: String, desc: '看板唯一编码'
          optional :page, type: Integer, default: 1
          optional :per_page, type: Integer, default: 20
          optional :role, type: Integer,   desc: '按角色筛选 0：查看 1: 编辑 2 管理员'
          optional :keyword, type: String, desc: '用户名/邮箱搜索关键词'
        end

        post :authorized_users do
          dashboard = Dashboard.find_by!(identifier: params[:identifier])
          creator_id = dashboard.user_id
          # 需要是看板成员或创建者才能查看权限列表
          require_dashboard_member!(dashboard)

          # 基础查询：所有活跃成员
          members_scope = dashboard.dashboard_members
                                   .includes(:user, :invited_by)
                                   .where(status: :active)
                                   .where('role < 2')


          # 角色筛选
          # if params[:role].present?
          #   members_scope = members_scope.where(role: params[:role])
          # end

          # 关键词搜索（用户名或邮箱）
          if params[:keyword].present?
            keyword = "%#{params[:keyword]}%"
            members_scope = members_scope.joins(:user).where(
              'users.name LIKE ? OR users.email LIKE ?', keyword, keyword
            )
          end

          # 排序：管理员在前，然后按加入时间倒序
          members_scope = members_scope.order(
            Arel.sql("CASE WHEN role = 'admin' THEN 0 WHEN role = 'editor' THEN 1 ELSE 2 END"),
            joined_at: :desc
          )

          page = params[:page]
          per_page = params[:per_page]

          total = members_scope.count
          paged_members = members_scope.offset((page - 1) * per_page).limit(per_page)

          result = paged_members.map do |member|
            {
              id: member.user_id,
              name: member.user.name,
              email: member.user.email,
              member_id: member.id,
              role: member.role,
              status: member.status,
              joined_at: member.joined_at&.strftime('%Y-%m-%d %H:%M:%S'),
              invited_by: member.invited_by&.name,
              is_owner: member.user_id == creator_id,
              remark: member.remark
            }
          end

          {
            total: total,
            page: page,
            per_page: per_page,
            data: result
          }

        rescue ActiveRecord::RecordNotFound
          error!({ error: '看板不存在' }, 404)
        end

        desc '批量更新看板成员角色',
             tags: ['CompassService / Compass服务'],
             hidden: true

        params do
          requires :identifier, type: String, desc: '看板唯一编码'
          requires :members, type: Array, desc: '成员列表' do
            requires :member_id, type: Integer, desc: '成员记录ID'
            requires :role, type: Integer,   desc: '新角色'
          end
        end

        desc '批量更新看板成员角色',
             tags: ['CompassService / Compass服务'],
             hidden: true

        params do
          requires :identifier, type: String, desc: '看板唯一编码'
          requires :members, type: Array, desc: '成员列表' do
            requires :member_id, type: Integer, desc: '成员记录ID'
            requires :role, type: Integer, desc: '角色: 0-viewer, 1-editor, 2-admin'
          end
        end

        post :update_member_roles do
          dashboard = Dashboard.find_by!(identifier: params[:identifier])
          require_dashboard_admin!(dashboard)

          members_params = params[:members]
          results = { success: [], failed: [], skipped: [] }

          DashboardMember.transaction do
            members_params.each do |member_param|
              member_id = member_param[:member_id]
              new_role = member_param[:role]

              member = dashboard.dashboard_members.find_by(id: member_id)

              unless member
                results[:failed] << { member_id: member_id, reason: '成员不存在' }
                next
              end

              if member.user_id == current_user.id
                results[:skipped] << { member_id: member_id, reason: '不能修改自己的角色' }
                next
              end

              if member.role == new_role
                results[:skipped] << { member_id: member_id, reason: '角色未变更' }
                next
              end

              if member.update(role: new_role)
                results[:success] << {
                  member_id: member.id,
                  user_id: member.user_id,
                  user_name: member.user.name,
                  role: new_role
                }
              else
                results[:failed] << {
                  member_id: member_id,
                  reason: member.errors.full_messages.join(', ')
                }
              end
            end
          end

          if results[:success].any?
            present({
                      status: results[:failed].any? || results[:skipped].any? ? 'partial_success' : 'success',
                      message: "成功更新 #{results[:success].length} 人，失败 #{results[:failed].length} 人，跳过 #{results[:skipped].length} 人",
                      data: results
                    })
          else
            error!({
                     status: 'failed',
                     message: '所有成员更新失败',
                     data: results
                   }, 422)
          end

        rescue ActiveRecord::RecordNotFound
          error!({ error: '看板不存在' }, 404)
        end

        desc '批量移除看板成员',
             tags: ['CompassService / Compass服务'],
             hidden: true

        params do
          requires :identifier, type: String, desc: '看板唯一编码'
          requires :member_ids, type: Array[Integer], desc: '成员记录ID列表'
        end

        post :remove_members do
          dashboard = Dashboard.find_by!(identifier: params[:identifier])
          require_dashboard_editor!(dashboard)

          member_ids = params[:member_ids]
          results = { success: [], failed: [], skipped: [] }

          DashboardMember.transaction do
            member_ids.each do |member_id|
              member = dashboard.dashboard_members.find_by(id: member_id)

              unless member
                results[:failed] << { member_id: member_id, reason: '成员不存在' }
                next
              end

              # 不能移除自己
              if member.user_id == current_user.id
                results[:skipped] << { member_id: member_id, reason: '不能移除自己' }
                next
              end

              # 检查是否是唯一管理员
              if member.admin? && dashboard.dashboard_members.where(role: :admin, status: :active).count == 1
                results[:skipped] << { member_id: member_id, reason: '不能移除唯一管理员' }
                next
              end

              if member.destroy
                results[:success] << {
                  member_id: member_id,
                  user_id: member.user_id,
                  user_name: member.user.name
                }
              else
                results[:failed] << {
                  member_id: member_id,
                  reason: '移除失败'
                }
              end
            end
          end

          if results[:success].any?
            present({
                      status: results[:failed].any? || results[:skipped].any? ? 'partial_success' : 'success',
                      message: "成功移除 #{results[:success].length} 人，失败 #{results[:failed].length} 人，跳过 #{results[:skipped].length} 人",
                      data: results
                    })
          else
            error!({
                     status: 'failed',
                     message: '所有成员移除失败',
                     data: results
                   }, 422)
          end

        rescue ActiveRecord::RecordNotFound
          error!({ error: '看板不存在' }, 404)
        end


      end
    end
  end
end

