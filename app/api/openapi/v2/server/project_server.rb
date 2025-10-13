# frozen_string_literal: true

module Openapi
  module V2
    module Server
      class ProjectServer < Grape::API
        version 'v2', using: :path
        prefix :api
        format :json

        before do
          require_login!
        end
        helpers Openapi::SharedParams::ErrorHelpers

        rescue_from :all do |e|
          case e
          when Grape::Exceptions::ValidationErrors
            handle_validation_error(e)
          when SearchFlip::ResponseError
            handle_open_search_error(e)
          when Openapi::Entities::InvalidVersionNumberError
            handle_release_error(e)
          else
            handle_generic_error(e)
          end
        end

        helpers do
          include Pagy::Backend

          def paginate_fun(scope)
            pagy(scope, page: params[:page], items: params[:per_page])
          end

          def count_of(base_indexer, cardinality_field)
            base_indexer
              .aggregate({ count: { cardinality: { field: cardinality_field } } })
              .per(0)
              .execute
              .aggregations
              .dig('count', 'value')
          end

          def project_update_distribution(base_indexer, terms_field)
            now = Time.now.to_i
            one_month = 30 * 24 * 60 * 60
            three_months = 3 * one_month
            six_months = 6 * one_month
            twelve_months = 12 * one_month

            stats = {
              within_1m: 0,
              over_1m: 0,
              over_3m: 0,
              over_6m: 0,
              over_12m: 0
            }

            after_key = nil

            loop do
              agg_body = {
                projects: {
                  composite: {
                    size: 1000,
                    sources: [
                      { origin: { terms: { field: terms_field } } }
                    ]
                  },
                  aggs: {
                    last_update: {
                      max: { field: 'metadata__updated_on' }
                    }
                  }
                }
              }

              agg_body[:projects][:composite][:after] = after_key if after_key

              resp = base_indexer
                       .aggregate(agg_body)
                       .per(0)
                       .execute

              buckets = resp.aggregations.dig('projects', 'buckets') || []
              buckets.each do |bucket|
                last_update_ts = bucket.dig('last_update', 'value')
                next unless last_update_ts

                diff = Time.now - last_update_ts
                if diff <= one_month
                  stats[:within_1m] += 1
                elsif diff > one_month && diff <= three_months
                  stats[:over_1m] += 1
                elsif diff > three_months && diff <= six_months
                  stats[:over_3m] += 1
                elsif diff > six_months && diff <= twelve_months
                  stats[:over_6m] += 1
                else
                  stats[:over_12m] += 1
                end
              end

              after_key = resp.aggregations.dig('projects', 'after_key')
              break unless after_key
            end

            stats
          end

        end

        resource :project_server do

          desc '项目概览', hidden: true, tags: ['admin'], success: {
            code: 201
          }, detail: '项目概览'

          params do
            requires :type, type: Integer, desc: '类型 0 孵化，1 毕业', documentation: { param_type: 'body' }
          end

          post :overview do
            type = params['type']
            github_count = 0
            gitee_count = 0
            gitcode_count = 0

            if type == 0
              projects = TpcSoftwareReportMetric.all
            else
              projects = TpcSoftwareGraduationReportMetric.all
            end
            projects.each do |project|
              url = project[:code_url].to_s.downcase.strip

              case
              when url.include?("github.com")
                github_count += 1
              when url.include?("gitee.com")
                gitee_count += 1
              when url.include?("gitcode.com")
                gitcode_count += 1
              end
            end

            {
              gitcode_count: gitcode_count,
              github_count: github_count,
              gitee_count: gitee_count
            }
          end

          desc '项目更新概览', hidden: true, tags: ['admin'], success: {
            code: 201
          }, detail: '项目更新概览'

          params do
            requires :type, type: Integer, desc: '类型 0 孵化，1 毕业', documentation: { param_type: 'body' }
          end

          post :update_overview do
            type = params['type']

            projects = type == 0 ? TpcSoftwareReportMetric.all : TpcSoftwareGraduationReportMetric.all

            now = Time.zone.now

            within_one_month = 0
            within_three_months = 0
            within_six_months = 0
            within_twelve_months = 0
            over_twelve_months = 0

            projects.each do |project|
              updated_at = project[:updated_at]
              next if updated_at.nil?

              diff_months = ((now.to_date - updated_at.to_date).to_i / 30.0).round(2)

              if diff_months <= 1
                within_one_month += 1
              elsif diff_months <= 3
                within_three_months += 1
              elsif diff_months <= 6
                within_six_months += 1
              elsif diff_months <= 12
                within_twelve_months += 1
              else
                over_twelve_months += 1
              end
            end

            {
              total: projects.count,
              updated_within_one_month: within_one_month,
              updated_within_three_months: within_three_months,
              updated_within_six_months: within_six_months,
              updated_within_twelve_months: within_twelve_months,
              updated_over_twelve_months: over_twelve_months
            }
          end

          desc '孵化项目列表', hidden: true, tags: ['admin'], success: {
            code: 201
          }, detail: '项目概览'

          params do
            optional :page, type: Integer, default: 1
            optional :per_page, type: Integer, default: 20
            optional :keywords, type: String, desc: '搜索关键字', documentation: { param_type: 'body', example: 'code' }
            optional :time_type, type: Integer, values: [0, 1, 3, 6, 12], desc: '更新时间范围（月）', documentation: { param_type: 'body', example: 1 }
            optional :platform, type: String, values: %w[github gitee gitcode], desc: '代码平台'
          end

          post :incubation_list do
            keywords = params['keywords']

            platform = params[:platform]
            time_type = params['time_type']
            start_time = nil
            end_time = nil

            case time_type
            when 0
              start_time = Time.now - 1.month
              end_time = Time.now
            when 1
              start_time = Time.now - 3.months
              end_time = Time.now - 1.month
            when 3
              start_time = Time.now - 6.months
              end_time = Time.now - 3.months
            when 6
              start_time = Time.now - 12.months
              end_time = Time.now - 6.months
            when 12
              end_time = Time.now - 12.months
            end

            items = TpcSoftwareSelectionReport
                      .joins(:tpc_software_selections)
                      .select('tpc_software_selection_reports.*, tpc_software_selections.state ')
                      .order("tpc_software_selection_reports.created_at DESC")

            items = items.where('tpc_software_selection_reports.name LIKE ?', "%#{keywords}%") if keywords.present?

            # 更新时间筛选
            if end_time.present? && start_time.present?
              items = items.where('tpc_software_selection_reports.updated_at': start_time..end_time)
            elsif start_time.present?
              items = items.where('tpc_software_selection_reports.updated_at >= ?', start_time)
            elsif end_time.present?
              items = items.where('tpc_software_selection_reports.updated_at <= ?', end_time)
            end

            # 平台筛选
            if platform.present?
              case platform
              when 'github'
                items = items.where("code_url LIKE ?", "%github.com%")
              when 'gitee'
                items = items.where("code_url LIKE ?", "%gitee.com%")
              when 'gitcode'
                items = items.where("code_url LIKE ?", "%gitcode.com%")
              end
            end

            pages, records = paginate_fun(items)

            datas = records.map do |r|
              binds = LoginBind.find_by(user_id: r.user_id)
              user_info = User.find_by(id: r.user_id)
              platform =
                case
                when r.code_url.include?("github.com")
                  "github"
                when r.code_url.include?("gitee.com")
                  "gitee"
                when r.code_url.include?("gitcode.com")
                  "gitcode"
                end
              {
                report_id: r.id,
                user_name: user_info&.name,
                state: r.state,
                name: r.name,
                platform: platform,
                code_url: r.code_url,
                created_at: r.created_at,
                updated_at: r.updated_at,
                login_binds: {
                  account: binds&.account,
                  provider: binds&.provider,
                  nickname: binds&.nickname,
                  avatar_url: binds&.avatar_url
                }
              }
            end

            {
              items: datas,
              total_count: pages.count,
              current_page: pages.page,
              per_page: pages.items,
              total_pages: pages.pages
            }
          end

          desc '毕业项目列表', hidden: true, tags: ['admin'], success: {
            code: 201
          }, detail: '毕业项目列表'

          params do
            optional :page, type: Integer, default: 1
            optional :per_page, type: Integer, default: 20
            optional :keywords, type: String, desc: '搜索关键字', documentation: { param_type: 'body', example: 'code' }
            optional :time_type, type: Integer, values: [0, 1, 3, 6, 12], desc: '更新时间范围（月）', documentation: { param_type: 'body', example: 1 }
            optional :platform, type: String, values: %w[github gitee gitcode], desc: '代码平台'
          end

          post :graduation_list do
            keywords = params[:keywords]

            platform = params[:platform]
            time_type = params[:time_type]

            items = TpcSoftwareGraduationReport
                      .joins(:tpc_software_graduations)
                      .select('tpc_software_graduation_reports.*, tpc_software_graduations.state ')
                      .order("tpc_software_graduation_reports.created_at DESC")

            items = items.where('tpc_software_graduation_reports.name LIKE ?', "%#{keywords}%") if keywords.present?

            case time_type
            when 0
              start_time = Time.now - 1.month
              end_time = Time.now
            when 1
              start_time = Time.now - 3.months
              end_time = Time.now - 1.month
            when 3
              start_time = Time.now - 6.months
              end_time = Time.now - 3.months
            when 6
              start_time = Time.now - 12.months
              end_time = Time.now - 6.months
            when 12
              end_time = Time.now - 12.months
            end
            # 更新时间筛选
            if end_time.present? && start_time.present?
              items = items.where('tpc_software_graduation_reports.updated_at': start_time..end_time)
            elsif start_time.present?
              items = items.where('tpc_software_graduation_reports.updated_at >= ?', start_time)
            elsif end_time.present?
              items = items.where('tpc_software_graduation_reports.updated_at <= ?', end_time)
            end

            # 平台筛选
            if platform.present?
              case platform
              when 'github'
                items = items.where("code_url LIKE ?", "%github.com%")
              when 'gitee'
                items = items.where("code_url LIKE ?", "%gitee.com%")
              when 'gitcode'
                items = items.where("code_url LIKE ?", "%gitcode.com%")
              end
            end

            pages, records = paginate_fun(items)

            datas = records.map do |r|
              binds = LoginBind.find_by(user_id: r.user_id)
              user_info = User.find_by(id: r.user_id)
              platform =
                case
                when r.code_url.include?("github.com")
                  "github"
                when r.code_url.include?("gitee.com")
                  "gitee"
                when r.code_url.include?("gitcode.com")
                  "gitcode"
                end
              {
                report_id: r.id,
                user_name: user_info&.name,
                state: r.state,
                name: r.name,
                platform: platform,
                code_url: r.code_url,
                created_at: r.created_at,
                updated_at: r.updated_at,
                login_binds: {
                  account: binds&.account,
                  provider: binds&.provider,
                  nickname: binds&.nickname,
                  avatar_url: binds&.avatar_url
                }

              }
            end

            {
              items: datas,
              total_count: pages.count,
              current_page: pages.page,
              per_page: pages.items,
              total_pages: pages.pages
            }
          end

          desc '项目平台数量分布', hidden: true, tags: ['admin'], success: {
            code: 201
          }, detail: '项目平台数量分布'
          params do
            requires :level, type: String, desc: 'repo 项目，community 社区', documentation: { param_type: 'body' }
          end
          post :project_platform_count do

            level = params['level']
            github_count = 0
            gitcode_count = 0
            gitee_count = 0

            if level == 'repo'

              # 查询repo_raw count
              github_count = count_of(GithubRepo, 'origin')
              gitcode_count = count_of(GitcodeRepo, 'origin')
              gitee_count = count_of(GiteeRepo, 'origin')
            elsif level == 'community'
              result = Subject
                         .joins("LEFT JOIN subject_refs sr ON sr.parent_id = subjects.id")
                         .joins("LEFT JOIN subjects c ON c.id = sr.child_id")
                         .where(level: 'community')
                         .pluck(
                           Arel.sql('COUNT(DISTINCT subjects.id) AS total_community_count'),
                           Arel.sql('COUNT(DISTINCT CASE WHEN c.label LIKE "%github.com%" THEN subjects.id END) AS github_community_count'),
                           Arel.sql('COUNT(DISTINCT CASE WHEN c.label LIKE "%gitee.com%" THEN subjects.id END) AS gitee_community_count'),
                           Arel.sql('COUNT(DISTINCT CASE WHEN c.label LIKE "%gitcode.com%" THEN subjects.id END) AS gitcode_community_count'),
                           Arel.sql('COUNT(DISTINCT CASE WHEN c.id IS NULL OR
                              (c.label NOT LIKE "%github.com%" AND
                               c.label NOT LIKE "%gitee.com%" AND
                               c.label NOT LIKE "%gitcode.com%")
                       THEN subjects.id END) AS other_platform_count')
                         ).first

              github_count = result[1]
              gitee_count = result[2]
              gitcode_count = result[3]
            end

            {
              github_count: github_count,
              gitee_count: gitee_count,
              gitcode_count: gitcode_count
            }

          end

          desc '项目更新数量分布', hidden: true, tags: ['admin'], success: {
            code: 201
          }, detail: '项目更新数量分布'
          params do
            requires :level, type: String, desc: 'repo 项目，community 社区', documentation: { param_type: 'body' }
          end
          post :project_platform_update_count do
            level = params['level']
            res = nil


            result = Subject.where(level: level)
                            .pluck(
                              Arel.sql("SUM(CASE WHEN updated_at >= NOW() - INTERVAL 1 MONTH THEN 1 ELSE 0 END) AS within_1m"),
                              Arel.sql("SUM(CASE WHEN updated_at < NOW() - INTERVAL 1 MONTH AND updated_at >= NOW() - INTERVAL 3 MONTH THEN 1 ELSE 0 END) AS over_1m"),
                              Arel.sql("SUM(CASE WHEN updated_at < NOW() - INTERVAL 3 MONTH AND updated_at >= NOW() - INTERVAL 6 MONTH THEN 1 ELSE 0 END) AS over_3m"),
                              Arel.sql("SUM(CASE WHEN updated_at < NOW() - INTERVAL 6 MONTH AND updated_at >= NOW() - INTERVAL 12 MONTH THEN 1 ELSE 0 END) AS over_6m"),
                              Arel.sql("SUM(CASE WHEN updated_at < NOW() - INTERVAL 12 MONTH THEN 1 ELSE 0 END) AS over_12m")
                            ).first

            res = {
              within_1m: result[0],
              over_1m: result[1],
              over_3m: result[2],
              over_6m: result[3],
              over_12m: result[4]
            }

            # if level == 'repo'
            #   github = project_update_distribution(GithubRepo, 'origin')
            #   gitee = project_update_distribution(GiteeRepo, 'origin')
            #   gitcode = project_update_distribution(GitcodeRepo, 'origin')
            #
            #   res = {
            #     within_1m: github[:within_1m].to_i + gitee[:within_1m].to_i + gitcode[:within_1m].to_i,
            #     over_1m: github[:over_1m].to_i + gitee[:over_1m].to_i + gitcode[:over_1m].to_i,
            #     over_3m: github[:over_3m].to_i + gitee[:over_3m].to_i + gitcode[:over_3m].to_i,
            #     over_6m: github[:over_6m].to_i + gitee[:over_6m].to_i + gitcode[:over_6m].to_i,
            #     over_12m: github[:over_12m].to_i + gitee[:over_12m].to_i + gitcode[:over_12m].to_i
            #   }
            #
            # elsif level == 'community'
            #   result = Subject.where(level: 'community')
            #                   .pluck(
            #                     Arel.sql("SUM(CASE WHEN updated_at >= NOW() - INTERVAL 1 MONTH THEN 1 ELSE 0 END) AS within_1m"),
            #                     Arel.sql("SUM(CASE WHEN updated_at < NOW() - INTERVAL 1 MONTH AND updated_at >= NOW() - INTERVAL 3 MONTH THEN 1 ELSE 0 END) AS over_1m"),
            #                     Arel.sql("SUM(CASE WHEN updated_at < NOW() - INTERVAL 3 MONTH AND updated_at >= NOW() - INTERVAL 6 MONTH THEN 1 ELSE 0 END) AS over_3m"),
            #                     Arel.sql("SUM(CASE WHEN updated_at < NOW() - INTERVAL 6 MONTH AND updated_at >= NOW() - INTERVAL 12 MONTH THEN 1 ELSE 0 END) AS over_6m"),
            #                     Arel.sql("SUM(CASE WHEN updated_at < NOW() - INTERVAL 12 MONTH THEN 1 ELSE 0 END) AS over_12m")
            #                   ).first
            #
            #   res = {
            #     within_1m: result[0],
            #     over_1m: result[1],
            #     over_3m: result[2],
            #     over_6m: result[3],
            #     over_12m: result[4]
            #   }
            # end

            res

          end

          desc '仓库列表图表', hidden: true, tags: ['admin'], success: {
            code: 201
          }, detail: '仓库列表图表'
          params do
            optional :page, type: Integer, default: 1
            optional :per_page, type: Integer, default: 20
            optional :keywords, type: String, desc: '搜索关键字', documentation: { param_type: 'body', example: 'code' }
            optional :time_type, type: Integer, values: [0, 1, 3, 6, 12], desc: '更新时间范围（月）', documentation: { param_type: 'body', example: 1 }
            optional :platform, type: String, values: %w[github gitee gitcode], desc: '代码平台'
          end
          post :repo_list do
            # 仓库列表图表
            keywords = params[:keywords]
            platform = params[:platform]
            time_type = params[:time_type]

            start_time = nil
            end_time = nil

            res = Subject.where(level: 'repo')
            res = res.where("label LIKE ?", "%#{keywords}%") if keywords.present?
            if platform.present?
              res = res.where("label LIKE ?", "%#{platform}%")
            end

            case time_type
            when 0
              start_time = Time.now - 1.month
              end_time = Time.now
            when 1
              start_time = Time.now - 3.months
              end_time = Time.now - 1.month
            when 3
              start_time = Time.now - 6.months
              end_time = Time.now - 3.months
            when 6
              start_time = Time.now - 12.months
              end_time = Time.now - 6.months
            when 12
              end_time = Time.now - 12.months
            end
            if start_time && end_time
              res = res.where(updated_at: start_time..end_time)
            elsif end_time
              res = res.where("updated_at <= ?", end_time)
            end

            pages, records = paginate_fun(res)

            datas = records.map do |r|
              # binds = LoginBind.find_by(user_id: sub.user_id)
              sub = Subscription.find_by(subject_id: r.id)
              user_info = User.find_by(id: sub&.user_id) if sub&.user_id.present?
              platform =
                case
                when r.label.include?("github.com")
                  "github"
                when r.label.include?("gitee.com")
                  "gitee"
                when r.label.include?("gitcode.com")
                  "gitcode"
                end
              now = Time.now
              updated_status =
                case now - r.updated_at
                when 0..1.month
                  "within_1m"
                when 1.month..3.months
                  "over_1m"
                when 3.months..6.months
                  "over_3m"
                when 6.months..12.months
                  "over_6m"
                else
                  "over_12m"
                end
              {
                label: r.label,
                user_name: user_info&.name,
                status: r.status,

                platform: platform,

                updated_at: r.updated_at,
                updated_status: updated_status,
                # 根据更新时间 返回描述 within_1m over_1m over_3m over_6m over_12m
                # login_binds: {
                #   account: binds&.account,
                #   provider: binds&.provider,
                #   nickname: binds&.nickname,
                #   avatar_url: binds&.avatar_url
                # }
              }
            end

            {
              items: datas,
              total_count: pages.count,
              current_page: pages.page,
              per_page: pages.items,
              total_pages: pages.pages
            }

          end

          desc '社区列表图表', hidden: true, tags: ['admin'], success: {
            code: 201
          }, detail: '社区列表图表'
          params do
            optional :page, type: Integer, default: 1
            optional :per_page, type: Integer, default: 20
            optional :keywords, type: String, desc: '搜索关键字', documentation: { param_type: 'body', example: 'code' }
            optional :time_type, type: Integer, values: [0, 1, 3, 6, 12], desc: '更新时间范围（月）', documentation: { param_type: 'body', example: 1 }
            optional :platform, type: String, values: %w[github gitee gitcode], desc: '代码平台'
          end
          post :community_list do
            # 仓库列表图表
            keywords = params[:keywords]
            platform = params[:platform]
            time_type = params[:time_type]

            start_time = nil
            end_time = nil

            # 基础查询：community
            res = Subject
                    .joins("JOIN subject_refs sr ON sr.parent_id = subjects.id")
                    .joins("JOIN subjects r ON sr.child_id = r.id")
                    .where(subjects: { level: 'community' })

            # 关键字搜索
            res = res.where("subjects.label LIKE ?", "%#{keywords}%") if keywords.present?

            # 平台过滤（用 repo label 判断）
            if platform.present?
              patt = case platform
                     when 'github' then '%github.com%'
                     when 'gitee' then '%gitee.com%'
                     when 'gitcode' then '%gitcode.com%'
                     else "%#{platform}%"
                     end
              res = res.where("r.label LIKE ?", patt)
            end

            # 时间范围
            case time_type
            when 0
              start_time = Time.now - 1.month
              end_time = Time.now
            when 1
              start_time = Time.now - 3.months
              end_time = Time.now - 1.month
            when 3
              start_time = Time.now - 6.months
              end_time = Time.now - 3.months
            when 6
              start_time = Time.now - 12.months
              end_time = Time.now - 6.months
            when 12
              end_time = Time.now - 12.months
            end
            if start_time && end_time
              res = res.where(r: { updated_at: start_time..end_time })
            elsif end_time
              res = res.where("r.updated_at <= ?", end_time)
            end

            # 先去重社区 ID，避免一个社区被多个 repo 膨胀
            id_scope = res.select('subjects.id').distinct

            total = id_scope.count

            # 分页
            pages, records = paginate_fun(id_scope.order('subjects.updated_at DESC'))

            # 回表拿社区详情
            community_ids = records.pluck(:id)
            communities = Subject.where(id: community_ids)

            datas = communities.map do |c|
              sub = Subscription.find_by(subject_id: c.id)
              user_info = User.find_by(id: sub&.user_id) if sub&.user_id.present?

              # 找到任意一个 repo 确定平台
              repo_label = Subject
                             .joins("JOIN subject_refs sr ON sr.child_id = subjects.id")
                             .where("sr.parent_id = ?", c.id)
                             .limit(1)
                             .pluck(:label)
                             .first

              platform =
                case
                when repo_label&.include?("github.com") then "github"
                when repo_label&.include?("gitee.com") then "gitee"
                when repo_label&.include?("gitcode.com") then "gitcode"
                else "unknown"
                end

              now = Time.now
              updated_status =
                case now - c.updated_at
                when 0..1.month then "within_1m"
                when 1.month..3.months then "over_1m"
                when 3.months..6.months then "over_3m"
                when 6.months..12.months then "over_6m"
                else "over_12m"
                end

              {
                label: c.label,
                user_name: user_info&.name,
                status: c.status,
                platform: platform,
                updated_at: c.updated_at,
                updated_status: updated_status
              }
            end

            {
              items: datas,
              total_count: total,
              current_page: pages.page,
              per_page: pages.items,
              total_pages: pages.pages
            }
          end



          desc '队列列表', hidden: true, tags: ['admin'], success: {
            code: 201
          }, detail: '队列列表'
          params do

          end
          post :queue_list do
            # 仓库列表图表



          end

        end
      end
    end
  end
end


