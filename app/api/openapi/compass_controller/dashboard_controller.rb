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
      end

      before { require_login! }

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

          base_scope = if current_user.role_level > 4
                         Dashboard.all
                       else
                         current_user.dashboards
                       end


          # dashboards_scope = base_scope.includes(:dashboard_models, :dashboard_metrics)
          #                              .order(created_at: :desc)
          # pages, records = paginate_fun(dashboards_scope)
          #
          # present({
          #           items: records.as_json(include: [:dashboard_models, :dashboard_metrics]),
          #           total_count: pages.count,
          #           current_page: pages.page,
          #           per_page: pages.items,
          #           total_pages: pages.pages
          #         })

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

          # 检查是否需要重新查询：最近3个月且每个指标数据只有2个
          need_refetch = is_recent_3_months && os_data_store.values.all? { |docs| docs.size == 2 }

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

          optional :filter_opts, type: Array do
            optional :type, type: String
            optional :values, type: Array[String]
          end

          optional :sort_opts, type: Array do
            optional :type, type: String
            optional :direction, type: String
          end
        end

        post :issues_detail_list do

          label = ShortenedLabel.normalize_label(params[:label])
          level = params[:level]
          page = params[:page]
          per = params[:per]
          begin_date = params[:beginDate]
          end_date = params[:endDate]

          filter_opts = (params[:filterOpts] || []).map { |opt| OpenStruct.new(opt) }
          # sort_opts = (params[:sortOpts] || []).map { |opt| OpenStruct.new(opt) }
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

          # validate_by_label!(current_user, label)
          #
          # begin_date, end_date, _interval = extract_date(params[:beginDate], params[:endDate])
          # validate_date!(current_user, label, level, begin_date, end_date)

          indexer, repo_urls = select_idx_repos_by_lablel_and_level(
            label,
            level,
            GiteeIssueEnrich,
            GithubIssueEnrich,
            GitcodeIssueEnrich
          )

          filter_opts << OpenStruct.new(type: 'pull_request', values: ['false'])



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

          # 将字段名定义为常量或局部变量，使用 String 格式匹配 _source 的 key
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
        ].freeze

          hits = resp&.dig('hits', 'hits') || []

          items = hits.map do |hit|
            source = hit['_source'] || {}

            # ALLOWED_FIELDS.each_with_object({}) do |field, hash|
            #   hash[field] = source[field]
            # end

            item_hash = ALLOWED_FIELDS.each_with_object({}) do |field, hash|
              hash[field] = source[field]
            end

            if item_hash['state'] == 'closed' && item_hash['time_to_first_attention_without_bot'].nil?
              item_hash['time_to_first_attention_without_bot'] = 0
            end

            if item_hash['num_of_comments_without_bot'].nil?
              item_hash['num_of_comments_without_bot'] = 0
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
        end

        post :issues_overview do

          label = ShortenedLabel.normalize_label(params[:label])
          level = params[:level]
          begin_date = params[:beginDate]
          end_date = params[:endDate]

          indexer, repo_urls = select_idx_repos_by_lablel_and_level(
            label,
            level,
            GiteeIssueEnrich,
            GithubIssueEnrich,
            GitcodeIssueEnrich
          )

          base_filter_opts = []
          base_filter_opts << OpenStruct.new(type: 'pull_request', values: ['false'])

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

        post :pulls_detail_list do

          label = ShortenedLabel.normalize_label(params[:label])
          level = params[:level]
          page = params[:page]
          per = params[:per]
          begin_date = params[:beginDate]
          end_date = params[:endDate]

          filter_opts = (params[:filterOpts] || []).map { |opt| OpenStruct.new(opt) }
          # sort_opts = (params[:sort_opts] || []).map { |opt| OpenStruct.new(opt) }
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
          # validate_by_label!(current_user, label)
          # begin_date, end_date, _ = extract_date(params[:beginDate], params[:endDate])
          # validate_date!(current_user, label, level, begin_date, end_date)

          indexer, repo_urls = select_idx_repos_by_lablel_and_level(
            label,
            level,
            GiteePullEnrich,
            GithubPullEnrich,
            GitcodePullEnrich
          )

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

          # 【可选】如果你有 Types::Meta::PullDetailType 定义的字段白名单，可以在这里过滤
          # 常见 PR 字段示例 (你可以根据实际需求修改 ALLOWED_FIELDS):
          ALLOWED_FIELDS = %w[
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
            hit['_source']

            # ALLOWED_FIELDS.each_with_object({}) do |field, hash|
            #   hash[field] = hit['_source'][field]
            # end

            item_hash = ALLOWED_FIELDS.each_with_object({}) do |field, hash|
              hash[field] = hit['_source'][field]
            end

            if item_hash['state'] == 'closed' && item_hash['time_to_first_attention_without_bot'].nil?
              item_hash['time_to_first_attention_without_bot'] = 0
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
              open_unresponsive_count: stat[:open_unresponsive_count]
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

      end
    end
  end
end

