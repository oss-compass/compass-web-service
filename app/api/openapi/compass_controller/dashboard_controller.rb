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

        def fetch_metrics_by_range(db_index_key, label, start_date, end_date)

          return {} if db_index_key.blank? || label.blank?
          metric_class = INDEX_CLASS_MAPPING[db_index_key]

          real_index_name = metric_class ? metric_class.index_name : db_index_key

          begin
            response = metric_class
                         .must(terms: { "label.keyword" => label })
                         .range(:grimoire_creation_date, gte: start_date, lte: end_date)
                         .sort(grimoire_creation_date: :asc)
                         .limit(100)
                         .execute
                         .raw_response

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
        end
        post :list do

          # puts current_user.to_json
          # # if current_user.role_level>4
          # dashboards_scope = current_user.dashboards
          #                                .includes(:dashboard_models, :dashboard_metrics)
          #                                .order(created_at: :desc)
          # pages, records = paginate_fun(dashboards_scope)
          #
          # present({
          #           items: records.as_json(include: [:dashboard_models, :dashboard_metrics]),
          #           total_count: pages.count,
          #           current_page: pages.page,
          #           per_page: pages.items,
          #           total_pages: pages.pages
          #         })

          base_scope = if current_user.role_level > 4
                         Dashboard.all
                       else
                         current_user.dashboards
                       end

          # 2. 统一进行预加载 (Includes) 和 排序 (Order)
          # 这样写可以避免代码重复，无论上面选了哪个范围，下面都统一处理
          dashboards_scope = base_scope.includes(:dashboard_models, :dashboard_metrics)
                                       .order(created_at: :desc)

          # 3. 分页处理
          pages, records = paginate_fun(dashboards_scope)

          # 4. 返回结果
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

          present dashboard.as_json(include: [:dashboard_models, :dashboard_metrics])
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

          # indexer, repo_urls, origin = select_idx_repos_by_lablel_and_level(
          #   target_label,
          #   level,
          #   GiteeContributorEnrich,
          #   GithubContributorEnrich,
          #   GitcodeContributorEnrich
          # )
          repo_urls = [target_label]

          os_data_store = {}
          index_scores = {}
          model_scores = []
          involved_indices = metrics.map { |m| m.dashboard_metric_info.metric_index }.uniq.compact

          involved_indices.each do |index_name|


            docs = fetch_metrics_by_range(index_name, repo_urls, start_date, end_date)
            os_data_store[index_name] = docs

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

            # docs = fetch_metrics_by_range(index_name, repo_urls, start_date, end_date)
            # os_data_store[index_name] = docs
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

          filter_opts = (params[:filter_opts] || []).map { |opt| OpenStruct.new(opt) }
          sort_opts = (params[:sort_opts] || []).map { |opt| OpenStruct.new(opt) }

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

          # 获取全量贡献者列表 (不分页)
          # 注意：这里获取的是经过基础处理的列表，通常是一个 Hash 数组
          full_contributors_list = indexer.fetch_contributors_list(
            repo_urls,
            begin_date,
            end_date,
            label: label,
            level: level
          )

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
            contributors_count: contributors_count,    # 贡献者总数
            top_contributors: top_contributors,        # Top 贡献者列表
            organizations_count: organizations_count,  # 贡献组织总数
            top_organizations: top_organizations       # Top 贡献组织列表
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

          filter_opts = (params[:filter_opts] || []).map { |opt| OpenStruct.new(opt) }
          sort_opts = (params[:sort_opts] || []).map { |opt| OpenStruct.new(opt) }

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

          # GitHub 的 issue 接口同时也包含 PR，需要通过 type: pull_request, values: ['false'] 来只获取 Issue
          if indexer == GithubIssueEnrich
            filter_opts << OpenStruct.new(type: 'pull_request', values: ['false'])
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

            ALLOWED_FIELDS.each_with_object({}) do |field, hash|
              hash[field] = source[field]
            end
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
          # 基础校验
          # validate_by_label!(current_user, label)

          label = ShortenedLabel.normalize_label(params[:label])
          level = params[:level]
          begin_date = params[:beginDate]
          end_date = params[:endDate]

          # 日期提取与校验
          # begin_date, end_date, _ = extract_date(begin_date, end_date)
          # validate_date!(current_user, label, level, begin_date, end_date)

          # 选择索引器
          indexer, repo_urls = select_idx_repos_by_lablel_and_level(
            label,
            level,
            GiteeIssueEnrich,
            GithubIssueEnrich,
            GitcodeIssueEnrich
          )

          # 定义基础过滤器
          # 针对 GitHub，Issue 接口包含 PR，必须全局排除 pull_request=true 的数据
          base_filter_opts = []
          if indexer == GithubIssueEnrich
            base_filter_opts << OpenStruct.new(type: 'pull_request', values: ['false'])
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
          # 注意：这里我们clone一下数组，避免污染 base_filter_opts
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
          # 字段名通常为 num_of_comments_without_bot 或 num_comments，根据你的索引定义调整
          unresponsive_filter = base_filter_opts + [
            OpenStruct.new(type: 'state', values: ['open']),
            OpenStruct.new(type: 'num_of_comments_without_bot', values: [0])
          ]

          unresponsive_issue_count = indexer.count_by_repo_urls(
            repo_urls,
            begin_date,
            end_date,
            filter_opts: unresponsive_filter
          )

          # 平均评论数量
          # 逻辑：需要对 num_of_comments_without_bot 字段进行 avg 聚合
          # 由于 count_by_repo_urls 仅返回数量，这里需要单独构建聚合查询
          # 如果你的 Indexer 没有封装 aggs 方法，可以使用底层的 client 或 SearchFlip

          avg_comments = 0
          begin
            # 使用 SearchFlip 或 Indexer 封装的聚合查询示例
            # 假设 indexer 有一个方法可以处理聚合，或者直接构造 DSL
            # 这里模拟一个 DSL 查询结构

            query_body = {
              query: {
                bool: {
                  must: [
                    { terms: { "label.keyword": repo_urls } },
                    { range: { "created_at": { gte: begin_date, lte: end_date } } }
                  ]
                }
              },
              aggs: {
                avg_val: { avg: { field: "num_of_comments_without_bot" } }
              },
              size: 0
            }

            # 将 GitHub 的 PR 过滤条件加入查询
            if indexer == GithubIssueEnrich
              query_body[:query][:bool][:must] << { term: { "pull_request": false } }
            end

            # 执行查询 (使用 indexer 关联的 client)
            # 注意：请根据实际的 indexer 实现调整 client 调用方式
            # client = OpenSearch::Client.new(url: ENV['OPENSEARCH_URL'])
            # response = client.search(index: indexer.index_name, body: query_body)
            # avg_comments = response.dig('aggregations', 'avg_val', 'value').to_f.round(2)

            # 临时占位，待你确认 indexer 是否有聚合方法后放开上述逻辑
            # 目前暂存为 0 或你需要实现 indexer.aggs_by_repo_urls(...)
            avg_comments = 0
          rescue => e
            # 异常处理，避免聚合失败导致整个接口报错
            Rails.logger.error "Avg comments calc error: #{e.message}"
          end

          # 返回结果
          {
            new_issue_count: new_issue_count,               # 新建 Issue 数
            issue_resolution_percentage: "#{resolution_percentage}%", # 解决率
            unresponsive_issue_count: unresponsive_issue_count, # 未响应数 (Open且0评论)
            avg_comments: avg_comments                      # 平均评论数
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
            OpenStruct.new(type: 'num_review_comments_without_bot', values: [0])  # 代码 Review 评论数为 0
          ]

          unresponsive_pr_count = pull_indexer.count_by_repo_urls(
            repo_urls, begin_date, end_date, filter_opts: unresponsive_filter
          )





          commit_indexer, _ = select_idx_repos_by_lablel_and_level(
            label, level, GiteeGitEnrich, GithubGitEnrich, GitcodeGitEnrich
          )


          commit_count = commit_indexer.count_by_repo_urls(repo_urls, begin_date, end_date)


          {
            new_pr_count: new_pr_count,                   # 新建 PR 数量
            pr_resolution_percentage: "#{resolution_percentage}%", # PR 解决百分比
            unresponsive_pr_count: unresponsive_pr_count, # 未响应 PR 数量
            commit_count: commit_count,                   # 代码提交数量


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

          filter_opts = (params[:filter_opts] || []).map { |opt| OpenStruct.new(opt) }
          sort_opts = (params[:sort_opts] || []).map { |opt| OpenStruct.new(opt) }

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
            # 如果不需要白名单过滤，直接返回 _source 即可
            hit['_source']

            # 如果需要像 Issue 那样严格过滤，请取消下面代码的注释并定义 ALLOWED_FIELDS
            ALLOWED_FIELDS.each_with_object({}) do |field, hash|
              hash[field] = hit['_source'][field]
            end
          end

          {
            count: count,
            total_page: (count.to_f / per).ceil,
            page: page,
            items: items
          }
        end

      end
    end
  end
end

