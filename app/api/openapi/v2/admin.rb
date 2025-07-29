# frozen_string_literal: true

module Openapi
  module V2
    class Admin < Grape::API
      version 'v2', using: :path
      prefix :api
      format :json
      require 'maxminddb'

      before { require_login! }
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
        # 计算总停留时长
        def calculate_total_duration(events)
          total = 0
          events.find_each do |event|
            data = JSON.parse(event.data || '{}')
            total += data['stay_duration'].to_i
          rescue JSON::ParserError
            next
          end
          total
        end

        # 计算变化率
        def calculate_change(current, previous)
          return 0.0 if previous.zero?

          ((current - previous).to_f / previous * 100).round(2)
        end

        # 格式化变化率
        def format_change(value)
          {
            value:,
            trend: if value.positive?
                     'up'
                   else
                     (value.negative? ? 'down' : 'flat')
                   end
          }
        end

        def ms_to_minutes(ms)
          return 0.0 if ms.to_f <= 0

          (ms.to_f / 1000 / 60).round(2)
        end
      end

      helpers do
        include Pagy::Backend
        def paginate_fun(scope)
          pagy(scope, page: params[:page], items: params[:per_page])
        end
      end

      resource :admin do
        desc '用户概览', hidden: true, tags: ['admin'], success: { code: 201 }, detail: '用户概览'
        params do
          requires :begin_date, type: DateTime, desc: 'Start date',
                   documentation: { param_type: 'body', example: '2010-02-22' }
          requires :end_date, type: DateTime, desc: 'End date',
                   documentation: { param_type: 'body', example: '2024-03-22' }
          end
          post :user_overview do
          # 时间范围

          current_start = params[:begin_date].to_date
          current_end = params[:end_date].to_date

          # 计算上一个周期的开始和结束时间

          period_length = (current_end - current_start).to_i + 1
          previous_end = current_start - 1
          previous_start = previous_end - (period_length - 1)

          # === 1. 注册用户数 ===
          current_sign_user = User.where(created_at: current_start..current_end).count
          previous_sign_user = User.where(created_at: previous_start..previous_end).count
          sign_user_change = calculate_change(current_sign_user, previous_sign_user)

          # === 2. 访问次数 ===
          current_visits = TrackingEvent.where(
            created_at: current_start..current_end,
            event_type: 'module_visit'
          ).count
          previous_visits = TrackingEvent.where(
            created_at: previous_start..previous_end,
            event_type: 'module_visit'
          ).count
          visit_change = calculate_change(current_visits, previous_visits)

          # === 3. 新用户数(IP+UA) ===
          current_new_users = TrackingEvent.where(
            created_at: current_start..current_end,
            event_type: 'module_visit'
          ).select(:ip, :device_user_agent).distinct.count
          previous_new_users = TrackingEvent.where(
            created_at: previous_start..previous_end,
            event_type: 'module_visit'
          ).select(:ip, :device_user_agent).distinct.count
          new_users_change = calculate_change(current_new_users, previous_new_users)

          # === 4. 平均活跃时长 ===
          # 当前月时长计算
          current_duration_events = TrackingEvent.where(
            created_at: current_start..current_end,
            event_type: 'module_stay'
          )
          current_duration = calculate_total_duration(current_duration_events)
          current_avg_duration = current_new_users.positive? ? current_duration / current_new_users : 0

          # 上个月时长计算
          previous_duration_events = TrackingEvent.where(
            created_at: previous_start..previous_end,
            event_type: 'module_stay'
          )
          previous_duration = calculate_total_duration(previous_duration_events)
          previous_avg_duration = previous_new_users.positive? ? previous_duration / previous_new_users : 0
          duration_change = calculate_change(current_avg_duration, previous_avg_duration)
          total_users_count = TrackingEvent.select(:ip, :device_user_agent).distinct.count
          # === 返回结果 ===
          {
            monthly_visit_count: current_visits,
            total_visit_count: TrackingEvent.where(event_type: 'module_visit').count,
            sign_user: current_sign_user,
            total_sign_user: User.count,
            new_users_count: current_new_users,
            total_users_count:,
            average_monthly_user_duration: Openapi::SharedParams::Utils.format_duration(current_avg_duration),
            total_average_user_duration: Openapi::SharedParams::Utils.format_duration(
              TrackingEvent.where(event_type: 'module_stay').count.zero? ? 0 : (calculate_total_duration(TrackingEvent.where(event_type: 'module_stay')) / total_users_count.to_f)
            ),
            # 新增环比字段
            monthly_visit_count_change: format_change(visit_change),
            sign_user_change: format_change(sign_user_change),
            new_users_count_change: format_change(new_users_change),
            average_monthly_user_duration_change: format_change(duration_change)
          }
        end

        desc '访问量图表', hidden: true, tags: ['admin'], success: {
          code: 201
        }, detail: '访问量图表'
        params do
          requires :begin_date, type: DateTime, desc: 'Start date',
                   documentation: { param_type: 'body', example: '2010-02-22' }
          requires :end_date, type: DateTime, desc: 'End date',
                   documentation: { param_type: 'body', example: '2024-03-22' }
          requires :type, type: Integer, desc: 'type: 类型 月0 、 年1 ', documentation: { param_type: 'body', example: 0 }
        end
        post :visit_count_table do
          begin_date = params[:begin_date].to_date
          end_date = params[:end_date].to_date
          type = params[:type]

          visit_events = TrackingEvent.where(
            event_type: 'module_visit',
            created_at: begin_date.beginning_of_day..end_date.end_of_day
          )

          result =
            case type
            when 0
              # 按天统计
              grouped = visit_events.group('DATE(created_at)').count
              (begin_date..end_date).map do |date|
                {
                  date: date.strftime('%Y-%m-%d'),
                  value: grouped[date] || 0
                }
              end

            when 1
              # 按月统计（用每月最后一天作为 date）
              grouped = visit_events.group("DATE_FORMAT(created_at, '%Y-%m')").count
              current = begin_date.beginning_of_month
              result = []

              while current <= end_date
                end_of_month = current.end_of_month
                month_key = current.strftime('%Y-%m')
                result << {
                  date: end_of_month.strftime('%Y-%m-%d'),
                  value: grouped[month_key] || 0
                }
                current = current.next_month
              end
              result

            else
              error!('非法 type 参数，必须为 0、1', 400)
            end

          result
        end

        desc '用户图表', hidden: true, tags: ['admin'], success: {
          code: 201
        }, detail: '用户图表'
        params do
          requires :begin_date, type: DateTime, desc: 'Start date',
                   documentation: { param_type: 'body', example: '2010-02-22' }
          requires :end_date, type: DateTime, desc: 'End date',
                   documentation: { param_type: 'body', example: '2024-03-22' }
          requires :type, type: Integer, desc: 'type: 类型 月0 、 年1 ', documentation: { param_type: 'body', example: 0 }
        end
        post :user_count_table do
          begin_date = params[:begin_date].to_date
          end_date = params[:end_date].to_date
          type = params[:type]

          sign_users = User.where(created_at: begin_date.beginning_of_day..end_date.end_of_day)
          # 活跃用户 = 新用户+留存用户
          # 留存用户就先看是否注册,user_id不为空
          # 新用户 就是ip和浏览器，同一个ip同一个user_agent就是一个用户，

          events = TrackingEvent.where(created_at: begin_date.beginning_of_day..end_date.end_of_day,
                                       event_type: 'module_visit')

          # 计算新用户（按 IP + UA 分组）
          result_new_users =
            case type
            when 0
              # 按天统计新用户（唯一 ip+ua 每天）
              grouped = events
                          .select('ip, device_user_agent, DATE(created_at) AS day')
                          .group('DATE(created_at)', 'ip', 'device_user_agent')
                          .group_by(&:day)
                          .transform_values(&:size)

              (begin_date..end_date).map do |date|
                {
                  date: date.strftime('%Y-%m-%d'),
                  value: grouped[date] || 0
                }
              end

            when 1
              # 按月统计新用户（唯一 ip+ua 每月）
              grouped = events
                          .select("ip, device_user_agent, DATE_FORMAT(created_at, '%Y-%m') AS month")
                          .group("DATE_FORMAT(created_at, '%Y-%m')", 'ip', 'device_user_agent')
                          .group_by(&:month)
                          .transform_values(&:size)

              current = begin_date.beginning_of_month
              result = []

              while current <= end_date
                end_of_month = current.end_of_month
                key = current.strftime('%Y-%m')
                result << {
                  date: end_of_month.strftime('%Y-%m-%d'),
                  value: grouped[key] || 0
                }
                current = current.next_month
              end

              result

            else
              error!('非法 type 参数，必须为 0、1', 400)
            end

          # 留存用户
          stay_events = events.where.not(user_id: nil)
          result_stay_users =
            case type
            when 0
              # 按天统计新用户（唯一 ip+ua 每天）
              grouped = stay_events
                          .select('ip, device_user_agent, DATE(created_at) AS day')
                          .group('DATE(created_at)', 'ip', 'device_user_agent')
                          .group_by(&:day)
                          .transform_values(&:size)

              (begin_date..end_date).map do |date|
                {
                  date: date.strftime('%Y-%m-%d'),
                  value: grouped[date] || 0
                }
              end

            when 1
              # 按月统计新用户（唯一 ip+ua 每月）
              grouped = stay_events
                          .select("ip, device_user_agent, DATE_FORMAT(created_at, '%Y-%m') AS month")
                          .group("DATE_FORMAT(created_at, '%Y-%m')", 'ip', 'device_user_agent')
                          .group_by(&:month)
                          .transform_values(&:size)

              current = begin_date.beginning_of_month
              result = []

              while current <= end_date
                end_of_month = current.end_of_month
                key = current.strftime('%Y-%m')
                result << {
                  date: end_of_month.strftime('%Y-%m-%d'),
                  value: grouped[key] || 0
                }
                current = current.next_month
              end

              result

            else
              error!('非法 type 参数，必须为 0、1', 400)
            end

          # 活跃用户
          result_active_users = result_new_users.each_with_index.map do |row, idx|
            {
              date: row[:date],
              value: row[:value] + result_stay_users[idx][:value]
            }
          end

          # 注册用户
          result_sign_users =
            case type
            when 0
              # 按天统计
              grouped = sign_users.group('DATE(created_at)').count
              (begin_date..end_date).map do |date|
                {
                  date: date.strftime('%Y-%m-%d'),
                  value: grouped[date] || 0
                }
              end

            when 1
              # 按月统计（用每月最后一天作为 date）
              grouped = sign_users.group("DATE_FORMAT(created_at, '%Y-%m')").count
              current = begin_date.beginning_of_month
              result = []

              while current <= end_date
                end_of_month = current.end_of_month
                month_key = current.strftime('%Y-%m')
                result << {
                  date: end_of_month.strftime('%Y-%m-%d'),
                  value: grouped[month_key] || 0
                }
                current = current.next_month
              end
              result

            else
              error!('非法 type 参数，必须为 0、1', 400)
            end

          # 用户留存率 留存用户/新用户
          result_stay_rate = result_new_users.each_with_index.map do |row, idx|
            new_val = row[:value]
            stay_val = result_stay_users[idx][:value]
            {
              date: row[:date],
              value: new_val.positive? ? ((stay_val.to_f / new_val) * 100).round(2) : 0
            }
          end


          #  按 Google Analytics 风格 留存率
          #  计算：过去6周内的用户（IP + UA）
          new_user_window_start = begin_date
          new_users_map = events
                            .where(created_at: new_user_window_start.beginning_of_day..new_user_window_start.end_of_day)
                            .select(:ip, :device_user_agent)
                            .distinct
                            .map { |e| "#{e.ip}|#{e.device_user_agent}" }
                            .to_set

          # 统计每日留存用户数
          result_retention_users = (begin_date..end_date).map do |date|
            day_users = events
                          .where(created_at: date.beginning_of_day..date.end_of_day)
                          .select(:ip, :device_user_agent)
                          .map { |e| "#{e.ip}|#{e.device_user_agent}" }

            retained_users = day_users.select { |user| new_users_map.include?(user) }.uniq

            {
              date: date.strftime('%Y-%m-%d'),
              value: (retained_users.size.to_f / new_users_map.size).round(2)
            }
          end

          # 用户转化率 注册用户/新用户
          result_transfer_rate = result_new_users.each_with_index.map do |row, idx|
            new_val = row[:value]
            sign_val = result_sign_users[idx][:value]
            {
              date: row[:date],
              value: new_val.positive? ? ((sign_val.to_f / new_val) * 100).round(2) : 0
            }
          end

          {
            # stay_rate: result_stay_rate,
            stay_rate: result_retention_users,
            sign_users: result_sign_users,
            new_users: result_new_users,
            stay_users: result_stay_users,
            active_users: result_active_users,
            transfer_rate: result_transfer_rate
          }
        end

        desc '用户列表', hidden: true, tags: ['admin'], success: {
          code: 201
        }, detail: '用户图表'
        params do
          requires :begin_date, type: DateTime, desc: 'Start date',
                   documentation: { param_type: 'body', example: '2010-02-22' }
          requires :end_date, type: DateTime, desc: 'End date',
                   documentation: { param_type: 'body', example: '2024-03-22' }
          optional :keywords, type: String, desc: 'keywords', documentation: { param_type: 'body', example: 'Nae' }
          optional :page, type: Integer, default: 1
          optional :per_page, type: Integer, default: 20
        end
        post :user_list do
          begin_date = params[:begin_date].to_date
          end_date = params[:end_date].to_date
          page = params[:page]
          per_page = params[:per_page]
          keywords = params[:keywords]

          users = User.all
          users = users.where('name LIKE :kw OR email LIKE :kw', kw: "%#{keywords}%") if keywords.present?
          user_ids = users.pluck(:id)

          # 查询报告数
          report_counts = TpcSoftwareSelectionReport
                            .where(user_id: user_ids)
                            .group(:user_id)
                            .count

          # 加载 GeoIP 数据库
          geo_db = MaxMindDB.new(Rails.root.join('db/GeoLite2-Country.mmdb'))

          # 获取所有 时长
          stay_events = TrackingEvent.where(created_at: begin_date.beginning_of_day..end_date.end_of_day,
                                            event_type: 'module_stay',
                                            user_id: user_ids)
          user_daily_durations = Hash.new { |h, k| h[k] = Hash.new(0) }

          stay_events.find_each do |event|
            data = JSON.parse(event.data || '{}')
            duration = data['stay_duration'].to_i
            next if duration <= 0

            user_id = event.user_id
            day = event.created_at.to_date
            user_daily_durations[user_id][day] += duration
          rescue JSON::ParserError
            next
          end

          # 每个用户的平均时长 = 所有天的 duration 之和 ÷ 活跃天数
          user_avg_durations = user_daily_durations.transform_values do |daily_map|
            durations = daily_map.values
            (durations.sum.to_f / durations.size).round(2)
          end

          # 获取所有点击事件
          events = TrackingEvent.where(
            created_at: begin_date.beginning_of_day..end_date.end_of_day,
            event_type: 'module_visit',
            user_id: user_ids
          )

          allowed_modules = %w[
            dataHub
            os-selection
            developer
            lab
            os-situation
            analyze
          ]

          # 初始化点击统计：{ user_id => { module => count } }
          user_click_stats = Hash.new { |h, k| h[k] = Hash.new(0) }

          events.find_each do |event|
            data = JSON.parse(event.data || '{}')
            mod = data['module']
            next if mod.blank?

            matched_key = allowed_modules.find { |keyword| mod.include?(keyword) }
            next unless matched_key

            user_click_stats[event.user_id][matched_key] += 1
          rescue JSON::ParserError
            next
          end

          total = users.size
          paged_users = users.offset((page - 1) * per_page).limit(per_page)

          result = paged_users.map do |user|
            avg_duration_ms = user_avg_durations[user.id] || 0
            avg_duration_min = ms_to_minutes(avg_duration_ms)
            record = geo_db.lookup(user.current_sign_in_ip)
            country = if record.found? && record.country.name.present?
                        record.country.name
                      else
                        'Unknown'
                      end
            binds = LoginBind.find_by(user_id: user.id)

            country_desc = Openapi::SharedParams::CityMap.to_cn(country)
            {
              id: user.id,
              name: user.name,
              ip: user.current_sign_in_ip,
              login_binds:{
                account: binds&.account,
                provider: binds&.provider,
                nickname: binds&.nickname,
                avatar_url: binds&.avatar_url,
              },
              country:,
              country_desc:,
              email: user.email,
              created_at: user.created_at.strftime('%Y-%m-%d %H:%M:%S'),
              avg_stay_per_day: avg_duration_min,
              click_stats: user_click_stats[user.id],
              report_count: report_counts[user.id] || 0
            }
          end.sort_by { |u| -u[:avg_stay_per_day] }

          {
            total:,
            page:,
            per_page:,
            data: result
          }
        end

        desc '管理用户列表', hidden: true, tags: ['admin'], success: {
          code: 201
        }, detail: '管理用户列表'
        params do
          optional :keywords, type: String, desc: 'keywords', documentation: { param_type: 'body', example: 'Nae' }
          optional :role_levels, type: Array[Integer],  desc: 'role', documentation: { param_type: 'body', example: 0 }
          optional :page, type: Integer, default: 1
          optional :per_page, type: Integer, default: 20
        end
        post :manage_user_list do
          page = params[:page]
          per_page = params[:per_page]
          keywords = params[:keywords]
          role_levels = params[:role_levels]

          users = User.all
          users = users.where('name LIKE :kw OR email LIKE :kw', kw: "%#{keywords}%") if keywords.present?

          users = users.where(role_level: role_levels) if role_levels.present?


          total = users.size
          paged_users = users.offset((page - 1) * per_page).limit(per_page)

          result = paged_users.map do |user|
            {
              id: user.id,
              name: user.name,
              email: user.email,
              last_sign_in_at: user.last_sign_in_at&.strftime('%Y-%m-%d %H:%M:%S'),
              role_level: user.role_level,
              role_level_desc: case user.role_level
                               when 0 then '普通用户'
                               when 2 then 'OH用户'
                               when 7 then '管理员'
                               else '普通用户'
                               end,
              created_at: user.created_at.strftime('%Y-%m-%d %H:%M:%S')

            }
          end

          {
            total:,
            page:,
            per_page:,
            data: result
          }
        end

        desc '修改用户权限', hidden: true, tags: ['admin'], success: {
          code: 201
        }, detail: '修改用户权限'
        params do
          requires :id, type: Integer, desc: '用户ID', documentation: { param_type: 'body', example: 1 }
          requires :role_level, type: Integer, desc: '角色权限（0=普通用户，2=OH用户，7=管理员）', documentation: { param_type: 'body', example: 7 }
        end
        post :update_user_role do
          user = User.find_by(id: params[:id])
          error!('用户不存在', 404) unless user

          unless [0, 2, 7].include?(params[:role_level])
            error!('非法的权限', 400)
          end

          user.update(role_level: params[:role_level])

          begin
            CompassRiak.delete('users', "user_#{user.id}")
          rescue => e
            Rails.logger.warn("Riak 删除用户缓存失败: #{e.message}")
          end

          {
            message: 'ok',
            user_id: user.id,
            new_role_level: user.role_level
          }

        end

        desc '用户平均时长图表', hidden: true, tags: ['admin'], success: {
          code: 201
        }, detail: '用户平均时长图表'
        params do
          requires :begin_date, type: DateTime, desc: 'Start date',
                   documentation: { param_type: 'body', example: '2010-02-22' }
          requires :end_date, type: DateTime, desc: 'End date',
                   documentation: { param_type: 'body', example: '2024-03-22' }
          requires :type, type: Integer, desc: 'type: 类型 月0 、 年1 ', documentation: { param_type: 'body', example: 0 }
        end
        post :user_duration_table do
          begin_date = params[:begin_date].to_date
          end_date = params[:end_date].to_date
          type = params[:type]

          user_duration = TrackingEvent.where(
            created_at: begin_date.beginning_of_day..end_date.end_of_day,
            event_type: 'module_stay'
          )

          # 结构：{ "2024-07-01" => { [ip, ua] => stay_duration_sum } }
          user_daily_duration = {}

          user_duration.find_each do |event|
            data = JSON.parse(event.data || '{}')
            stay_duration = data['stay_duration'].to_i # 毫秒

            ip = event.ip
            ua = event.device_user_agent

            time_key =
              case type
              when 0
                event.created_at.to_date.strftime('%Y-%m-%d') # 每天
              when 1
                event.created_at.to_date.end_of_month.strftime('%Y-%m-%d') # 每月
              else
                error!('非法 type 参数，必须为 0（天）或 1（月）', 400)
              end

            user_key = [ip, ua]
            user_daily_duration[time_key] ||= {}
            user_daily_duration[time_key][user_key] ||= 0
            user_daily_duration[time_key][user_key] += stay_duration
          rescue JSON::ParserError
            next
          end

          # 输出格式：[{ date: ..., value: ... }]
          result = []

          time_range =
            if type.zero?
              (begin_date..end_date).map { |d| d.strftime('%Y-%m-%d') }
            else
              current = begin_date.beginning_of_month
              res = []
              while current <= end_date
                res << current.end_of_month.strftime('%Y-%m-%d')
                current = current.next_month
              end
              res
            end

          time_range.each do |date_key|
            users = user_daily_duration[date_key] || {}
            total_duration = users.values.sum
            user_count = users.keys.uniq.size

            avg_minutes = user_count.positive? ? (total_duration / 1000.0 / 60 / user_count).round(2) : 0

            Rails.logger.debug do
              "Date: #{date_key}, Total Duration: #{total_duration}, User Count: #{user_count}, Avg Minutes: #{avg_minutes}"
            end

            result << {
              date: date_key,
              value: avg_minutes
            }
          end

          result
        end

        desc '按国家/地区划分的活跃用户', hidden: true, tags: ['admin'], success: {
          code: 201
        }, detail: '按国家/地区划分的活跃用户'
        params do
          requires :begin_date, type: DateTime, desc: 'Start date',
                   documentation: { param_type: 'body', example: '2010-02-22' }
          requires :end_date, type: DateTime, desc: 'End date',
                   documentation: { param_type: 'body', example: '2024-03-22' }
          requires :type, type: Integer, desc: 'type: 类型 月0 、 年1 ', documentation: { param_type: 'body', example: 0 }
          requires :user_type, type: Integer, desc: 'user_type: 类型 活跃用户0 、 新增用户1 ', documentation: { param_type: 'body', example: 0 }
        end
        post :user_region_table do
          begin_date = params[:begin_date].to_date.beginning_of_day
          end_date = params[:end_date].to_date.end_of_day

          # 加载 GeoIP 数据库
          geo_db = MaxMindDB.new(Rails.root.join('db/GeoLite2-Country.mmdb'))

          country_user_count = Hash.new(0)

          if params[:user_type] == 0
            # === 活跃用户 ===
            events = TrackingEvent
                       .where(created_at: begin_date..end_date, event_type: 'module_visit')
                       .group(:ip, :device_user_agent)

            events.find_each do |event|
              ip = event.ip
              record = geo_db.lookup(ip)

              country = if record.found? && record.country.name.present?
                          record.country.name
                        else
                          'Unknown'
                        end

              country_user_count[country] += 1
            end

          elsif params[:user_type] == 1
            # === 新增用户 ===
            events = TrackingEvent
                       .where(created_at: begin_date..end_date, event_type: 'module_visit', user_id: nil)
                       .group(:ip, :device_user_agent)

            events.find_each do |event|
              ip = event.ip
              record = geo_db.lookup(ip)

              country = if record.found? && record.country.name.present?
                          record.country.name
                        else
                          'Unknown'
                        end

              country_user_count[country] += 1
            end
          else
            error!('非法的 user_type 参数', 400)
          end

          result = country_user_count.map do |country, count|
            {
              country: country,
              value: count,
              desc: Openapi::SharedParams::CityMap.to_cn(country)
            }
          end.sort_by { |item| -item[:value] }

          result
        end

        desc '服务点击量占比图', hidden: true, tags: ['admin'], success: {
          code: 201
        }, detail: '服务点击量占比图'
        params do
          requires :begin_date, type: DateTime, desc: 'Start date',
                   documentation: { param_type: 'body', example: '2010-02-22' }
          requires :end_date, type: DateTime, desc: 'End date',
                   documentation: { param_type: 'body', example: '2024-03-22' }
        end
        post :service_visit_table do
          begin_date = params[:begin_date].to_date
          end_date = params[:end_date].to_date

          allowed_modules = %w[
            dataHub
            os-selection
            developer
            lab
            os-situation
            analyze
          ]

          visit_events = TrackingEvent.where(
            event_type: 'module_visit',
            created_at: begin_date.beginning_of_day..end_date.end_of_day
          )

          module_counts = Hash.new(0)

          visit_events.find_each do |event|
            data = JSON.parse(event.data || '{}')
            raw_module = data['module']
            next if raw_module.blank?

            matched_key = allowed_modules.find { |keyword| raw_module.include?(keyword) }
            next unless matched_key

            module_counts[matched_key] += 1
          rescue JSON::ParserError
            next
          end

          result = module_counts.map do |mod, count|
            { name: mod, value: count }
          end

          result.sort_by { |item| -item[:value] }
        end

        desc '服务点击量趋势图', hidden: true, tags: ['admin'], success: {
          code: 201
        }, detail: '服务点击量趋势图'
        params do
          requires :begin_date, type: DateTime, desc: 'Start date',
                   documentation: { param_type: 'body', example: '2025-06-01' }
          requires :end_date, type: DateTime, desc: 'End date',
                   documentation: { param_type: 'body', example: '2025-07-01' }
          requires :type, type: Integer, desc: 'type: 类型 月0 、 年1 ', documentation: { param_type: 'body', example: 0 }
        end
        post :service_visit_trend_table do
          begin_date = params[:begin_date].to_date
          end_date = params[:end_date].to_date
          type = params[:type]

          allowed_modules = %w[
            dataHub
            os-selection
            developer
            lab
            os-situation
            analyze
          ]

          # 构建时间分组条件
          visit_events = TrackingEvent.where(
            event_type: 'module_visit',
            created_at: begin_date.beginning_of_day..end_date.end_of_day
          )

          daily_module_counts = Hash.new { |hash, key| hash[key] = Hash.new(0) }

          visit_events.find_each do |event|
            data = JSON.parse(event.data || '{}')
            raw_module = data['module']
            next if raw_module.blank?

            matched_key = allowed_modules.find { |keyword| raw_module.include?(keyword) }
            next unless matched_key

            day = event.created_at.to_date.strftime('%Y-%m-%d')
            daily_module_counts[day][matched_key] += 1
          rescue JSON::ParserError
            next
          end

          # 构建返回结果，按天返回每个模块的点击量
          result = (begin_date..end_date).map do |date|
            day_str = date.strftime('%Y-%m-%d')
            {
              date: day_str,
              modules: allowed_modules.map do |mod|
                {
                  name: mod,
                  value: daily_module_counts.dig(day_str, mod) || 0
                }
              end
            }
          end
          result
        end

        desc '开源态势洞察维度点击量排名', hidden: true, tags: ['admin'], success: {
          code: 201
        }, detail: '开源态势洞察维度点击量排名'
        params do
          requires :begin_date, type: DateTime, desc: 'Start date',
                   documentation: { param_type: 'body', example: '2010-02-22' }
          requires :end_date, type: DateTime, desc: 'End date',
                   documentation: { param_type: 'body', example: '2024-03-22' }
        end
        post :os_situation_visit_table do
          begin_date = params[:begin_date].to_date
          end_date = params[:end_date].to_date

          visit_events = TrackingEvent.where(
            event_type: 'module_visit',
            created_at: begin_date.beginning_of_day..end_date.end_of_day,
            module_id: 'os-situation'
          )

          module_counts = Hash.new(0)

          visit_events.find_each do |event|
            data = JSON.parse(event.data || '{}')
            raw_module = data['type']
            next if raw_module.blank?

            module_counts[raw_module] += 1
          rescue JSON::ParserError
            next
          end

          result = module_counts.map do |mod, count|
            { name: mod, value: count }
          end

          result.sort_by { |item| -item[:value] }
        end

        desc '用户跳转来源', hidden: true, tags: ['admin'], success: {
          code: 201
        }, detail: '用户跳转来源'
        params do
          requires :begin_date, type: DateTime, desc: 'Start date',
                   documentation: { param_type: 'body', example: '2010-02-22' }
          requires :end_date, type: DateTime, desc: 'End date',
                   documentation: { param_type: 'body', example: '2024-03-22' }
        end
        post :user_referrer_table do
          begin_date = params[:begin_date].to_date
          end_date = params[:end_date].to_date

          not_count = %w[
            https://oss-compass.org
            http://oss-compass.org
            https://compass.gitee.com
            http://compass.gitee.com
            http://localhost:3000/
          ]

          visit_events = TrackingEvent.where(
            event_type: 'module_visit',
            created_at: begin_date.beginning_of_day..end_date.end_of_day
          )

          referrer_counts = Hash.new(0)

          visit_events.find_each do |event|
            referrer = event.referrer

            next if referrer.blank?
            next if not_count.any? { |key| referrer.include?(key) }

            referrer_counts[referrer] += 1
          rescue JSON::ParserError
            next
          end

          result = referrer_counts.map do |mod, count|
            { name: mod, value: count }
          end

          result.sort_by { |item| -item[:value] }
        end

        desc '开源选型评估服务点击量占比', hidden: true, tags: ['admin'], success: {
          code: 201
        }, detail: '开源选型评估服务点击量占比'
        params do
          requires :begin_date, type: DateTime, desc: 'Start date',
                   documentation: { param_type: 'body', example: '2010-02-22' }
          requires :end_date, type: DateTime, desc: 'End date',
                   documentation: { param_type: 'body', example: '2024-03-22' }
        end
        post :oss_selection_click_table do
          begin_date = params[:begin_date].to_date
          end_date = params[:end_date].to_date

          visit_events = TrackingEvent.where(
            event_type: 'module_click',
            created_at: begin_date.beginning_of_day..end_date.end_of_day,
            module_id: %w[similar_software_section os-selection]
          )

          module_counts = Hash.new(0)

          raw_map = %w[similar_software_section recommendation_section_search assessment_section_search]

          visit_events.find_each do |event|
            data = JSON.parse(event.data || '{}')
            raw_module = data['type']
            next if raw_module.blank?

            # 如果是 'click'，统一归为 'similar_software_section'
            raw_module = 'similar_software_section' if raw_module == 'click'
            next unless raw_map.include?(raw_module)

            module_counts[raw_module] += 1
          rescue JSON::ParserError
            next
          end

          result = module_counts.map do |mod, count|
            { name: mod, value: count }
          end

          result.sort_by { |item| -item[:value] }
        end

        desc '开源选型评估服务搜索明细表', hidden: true, tags: ['admin'], success: {
          code: 201
        }, detail: '开源选型评估服务搜索明细表'
        params do
          requires :begin_date, type: DateTime, desc: 'Start date',
                   documentation: { param_type: 'body', example: '2010-02-22' }
          requires :end_date, type: DateTime, desc: 'End date',
                   documentation: { param_type: 'body', example: '2024-03-22' }
          optional :page, type: Integer, default: 1
          optional :per_page, type: Integer, default: 20
        end
        post :oss_selection_search_table do
          begin_date = params[:begin_date].to_date
          end_date = params[:end_date].to_date
          page = params[:page]
          per_page = params[:per_page]

          visit_events = TrackingEvent.where(
            event_type: 'module_click',
            created_at: begin_date.beginning_of_day..end_date.end_of_day,
            module_id: %w[similar_software_section os-selection]
          )

          raw_map = %w[similar_software_section recommendation_section_search assessment_section_search]

          result = []

          visit_events.find_each do |event|
            data = JSON.parse(event.data || '{}')
            raw_module = data['type']
            search_content = data['content']
            next if raw_module.blank? || search_content.blank?
            next if event.user_id.blank?

            raw_module = 'similar_software_section' if raw_module == 'click'
            next unless raw_map.include?(raw_module)

            result << {
              module_type: raw_module,
              content: search_content,
              user_id: event.user_id,
              user_name: event.user&.name || '未知用户',
              searched_at: event.created_at.strftime('%Y-%m-%d %H:%M:%S')
            }
          rescue JSON::ParserError
            next
          end

          total = result.size
          paged_result = result.slice((page - 1) * per_page, per_page) || []

          {
            total:,
            page:,
            per_page:,
            data: paged_result
          }
        end

        desc '开源选型评估服务搜索明细表 下载', hidden: true, tags: ['admin'], success: {
          code: 201
        }, detail: '开源选型评估服务搜索明细表 下载'
        get :oss_selection_search_table_download do
          begin_date = params[:begin_date].to_date
          end_date = params[:end_date].to_date

          visit_events = TrackingEvent.where(
            event_type: 'module_click',
            created_at: begin_date.beginning_of_day..end_date.end_of_day,
            module_id: %w[similar_software_section os-selection]
          )

          raw_map = %w[similar_software_section recommendation_section_search assessment_section_search]

          csv_data = CSV.generate(headers: true) do |csv|
            csv << %w[模块类型 搜索内容 用户ID 用户名称 搜索时间]

            visit_events.find_each do |event|
              data = JSON.parse(event.data || '{}')
              raw_module = data['type']
              search_content = data['content']
              next if raw_module.blank? || search_content.blank?
              next if event.user_id.blank?

              raw_module = 'similar_software_section' if raw_module == 'click'
              next unless raw_map.include?(raw_module)

              # 将 content 转为 JSON 字符串，避免乱格式
              content_str = JSON.dump(search_content)

              csv << [
                raw_module,
                content_str,
                event.user_id,
                event.user&.name || '未知',
                event.created_at.strftime('%Y-%m-%d %H:%M:%S')
              ]
            rescue JSON::ParserError
              next
            end
          end

          content_type 'text/csv'
          header['Content-Disposition'] = "attachment; filename=search_export_#{begin_date}_to_#{end_date}.csv"
          env['api.format'] = :binary
          body csv_data
        end

        desc '仓库/社区、开发者热门搜索排名', hidden: true, tags: ['admin'], success: {
          code: 201
        }, detail: '仓库/社区、开发者热门搜索排名'
        params do
          requires :begin_date, type: DateTime, desc: 'Start date',
                   documentation: { param_type: 'body', example: '2010-02-22' }
          requires :end_date, type: DateTime, desc: 'End date',
                   documentation: { param_type: 'body', example: '2024-03-22' }
          requires :type, type: String, desc: '类型，repo:仓库 ， developer:开发者',
                   documentation: { param_type: 'body', example: 'collection' }
        end
        post :collection_search_rank do
          begin_date = params[:begin_date].to_date
          end_date = params[:end_date].to_date
          type = params[:type]

          visit_events = nil

          visit_events = if type == 'developer'
                           TrackingEvent.where(
                             event_type: 'module_visit',
                             created_at: begin_date.beginning_of_day..end_date.end_of_day,
                             module_id: 'developer'
                           )
                         else
                           TrackingEvent.where(
                             event_type: 'module_visit',
                             created_at: begin_date.beginning_of_day..end_date.end_of_day,
                             module_id: 'analyze'
                           )
                         end

          module_counts = Hash.new(0)

          visit_events.find_each do |event|
            data = JSON.parse(event.data || '{}')
            raw_module = data['type'][0]
            next if raw_module.blank?

            module_counts[raw_module] += 1
          rescue JSON::ParserError
            next
          end

          labels = ShortenedLabel.where(short_code: module_counts.keys).pluck(:short_code, :label).to_h
          result = module_counts.map do |mod, count|
            { name: mod, label: labels[mod] || mod, value: count }
          end

          result.sort_by { |item| -item[:value] }.first(10)
        end

        desc '开源数据中枢API点击量排名', hidden: true, tags: ['admin'], success: {
          code: 201
        }, detail: '开源数据中枢API点击量排名'
        params do
          requires :begin_date, type: DateTime, desc: 'Start date',
                   documentation: { param_type: 'body', example: '2010-02-22' }
          requires :end_date, type: DateTime, desc: 'End date',
                   documentation: { param_type: 'body', example: '2024-03-22' }
        end
        post :datahub_api_rank do
          begin_date = params[:begin_date].to_date
          end_date = params[:end_date].to_date

          visit_events =
            TrackingEvent.where(
              event_type: 'module_click',
              created_at: begin_date.beginning_of_day..end_date.end_of_day,
              module_id: 'dataHub'
            )

          module_counts = Hash.new(0)

          visit_events.find_each do |event|
            data = JSON.parse(event.data || '{}')
            raw_module = data['content']['menu_key']
            raw_type = data['type']
            next if raw_module.blank?
            next unless raw_type == 'rest_api'

            module_counts[raw_module] += 1
          rescue JSON::ParserError
            next
          end

          result = module_counts.map do |mod, count|
            { name: mod, desc: Openapi::SharedParams::APIMap.to_en(mod) || '', value: count }
          end

          result.sort_by { |item| -item[:value] }.first(10)
        end

        desc '开源数据中枢archive下载量排名', hidden: true, tags: ['admin'], success: {
          code: 201
        }, detail: '开源数据中枢archive下载量排名'
        params do
          requires :begin_date, type: DateTime, desc: 'Start date',
                   documentation: { param_type: 'body', example: '2010-02-22' }
          requires :end_date, type: DateTime, desc: 'End date',
                   documentation: { param_type: 'body', example: '2024-03-22' }
        end
        post :datahub_archive_rank do
          begin_date = params[:begin_date].to_date
          end_date = params[:end_date].to_date

          visit_events =
            TrackingEvent.where(
              event_type: 'module_click',
              created_at: begin_date.beginning_of_day..end_date.end_of_day,
              module_id: 'dataHub'
            )

          module_counts = Hash.new(0)

          name_map = {
            'Contribution Dataset' => '贡献量数据集',
            'Contributor Dataset' => '贡献者数据集',
            'Import & Export Dataset' => '进出口数据集',
            'Language Dataset' => '编程语言数据集',
            'License Dataset' => '许可证数据集',
            'Repository Dataset' => '仓库数据集',
            'Technology Domain Dataset' => '仓库数据集'
          }
          visit_events.find_each do |event|
            data = JSON.parse(event.data || '{}')
            raw_module = data['content']['dataset_name']
            # 如果在name_map中有对应的中文名称，则使用中文名称
            raw_module = name_map[raw_module] if name_map.key?(raw_module)
            raw_type = data['type']
            next if raw_module.blank?
            next unless raw_type == 'archive_download'

            module_counts[raw_module] += 1
          rescue JSON::ParserError
            next
          end

          result = module_counts.map do |mod, count|
            { name: mod, value: count }
          end

          result.sort_by { |item| -item[:value] }.first(10)
        end

        desc '开源数据中枢API请求量',hidden: true, tags: ['admin'], success: {
          code: 201
        }, detail: '开源数据中枢API请求量'
        params do
          requires :begin_date, type: DateTime, desc: 'Start date', documentation: { param_type: 'body', example: '2010-02-22' }
          requires :end_date, type: DateTime, desc: 'End date', documentation: { param_type: 'body', example: '2024-03-22' }
          optional :keywords, type: String, desc: 'Keywords 用户名或邮箱', documentation: { param_type: 'body', example: '' }
          optional :api_path, type: String, desc: 'restapi', documentation: { param_type: 'body', example: '/api/v2/metadata/releases' }
          optional :page, type: Integer, default: 1
          optional :per_page, type: Integer, default: 20

        end
        post :datahub_restapi_table do
          begin_date = params[:begin_date].to_date
          end_date = params[:end_date].to_date
          keywords = params[:keywords]
          api = params[:api_path]

          user_ids = nil
          if keywords.present?
            users = User.where('name LIKE :kw OR email LIKE :kw', kw: "%#{keywords}%")
            user_ids = users.pluck(:id)
          end

          restapi = TrackingRestapi.where(created_at: begin_date..end_date)
          restapi = restapi.where(user_id: user_ids) if user_ids.present?
          restapi = restapi.where(api_path: api) if api.present?

          result = restapi
                     .group('tracking_restapis.user_id', 'tracking_restapis.api_path')
                     .select(
                       'tracking_restapis.user_id',
                       'tracking_restapis.api_path',
                       'COUNT(*) AS call_count',
                       'MAX(tracking_restapis.created_at) AS last_called_at'
                     )
                     .order(Arel.sql('COUNT(*) DESC'))

          pages, paginated_result = paginate_fun(result)


          items = paginated_result.map do |r|
            binds = LoginBind.find_by(user_id: r.user_id)

            {
              user_id: r.user_id,
              login_binds: {
                account: binds&.account,
                provider: binds&.provider,
                nickname: binds&.nickname,
                avatar_url: binds&.avatar_url
              },
              api_path: r.api_path,
              call_count: r.call_count,
              last_called_at: r.last_called_at
            }
          end

          {
            items: items,
            total_count: pages.count,
            current_page: pages.page,
            per_page: pages.items,
            total_pages: pages.pages
          }
        end

        desc '开源数据中枢API列表', hidden: true, tags: ['admin'], success: {
          code: 201
        }, detail: '开源数据中枢API请求量'
        params do
        end
        get :datahub_restapi_list do
          domin = ENV.fetch('NOTIFICATION_URL')
          body = Faraday.get("#{domin}/api/v2/docs").body
          swagger_doc = JSON.parse(body)

          paths = swagger_doc['paths'].map do |path, methods|
            methods.map do |method, details|
              {
                api_path: path,
                description: details['description'] || ''
              }
            end
          end

          paths.flatten
          end

        desc '开源数据中枢归档数据下载量', hidden: true, tags: ['admin'], success: {
          code: 201
        }, detail: '开源数据中枢归档数据下载量'
        params do
          requires :begin_date, type: DateTime, desc: 'Start date', documentation: { param_type: 'body', example: '2010-02-22' }
          requires :end_date, type: DateTime, desc: 'End date', documentation: { param_type: 'body', example: '2024-03-22' }
          optional :keywords, type: String, desc: 'Keywords 用户名或邮箱', documentation: { param_type: 'body', example: '' }
          optional :dataset_name, type: String, desc: 'dataset_name', documentation: { param_type: 'body', example: '贡献者数据集' }
          optional :page, type: Integer, default: 1
          optional :per_page, type: Integer, default: 20

        end
        post :datahub_archive_download_table do
          begin_date = params[:begin_date].to_date
          end_date = params[:end_date].to_date
          keywords = params[:keywords]
          dataset = params[:dataset_name]


          user_ids = nil
          if keywords.present?
            users = User.where('name LIKE :kw OR email LIKE :kw', kw: "%#{keywords}%")
            user_ids = users.pluck(:id)
          end

          archive_download = TrackingEvent.where(created_at: begin_date..end_date, module_id: 'dataHub', event_type: 'module_click')
                                          .where("data LIKE ?", "%archive_download%").where.not(user_id: nil)
          archive_download = archive_download.where(user_id: user_ids) if user_ids.present?
          archive_download = archive_download.where("data LIKE ?", "%#{dataset}%") if dataset.present?


          pages, paginated_result = paginate_fun(archive_download)
          stat = {}
          paginated_result.find_each do |event|
            begin
              parsed_data = JSON.parse(event.data)
              next unless parsed_data["type"] == "archive_download"
              dataset_name = parsed_data.dig("content", "dataset_name")
              next unless dataset_name

              key = [event.user_id, dataset_name]

              stat[key] ||= { user_id: event.user_id, dataset_name: dataset_name, call_count: 0, last_called_at: nil }
              stat[key][:call_count] += 1
              stat[key][:last_called_at] = [stat[key][:last_called_at], event.created_at].compact.max
            rescue JSON::ParserError
              next
            end
          end

          result = stat.values.sort_by { |r| -r[:call_count] }
          items = result.map do |r|

            binds = LoginBind.find_by(user_id: r[:user_id])

            {
              user_id: r[:user_id],
              login_binds: {
                account: binds&.account,
                provider: binds&.provider,
                nickname: binds&.nickname,
                avatar_url: binds&.avatar_url
              },

              call_count: r[:call_count],
              last_called_at: r[:last_called_at],
              dataset_name: r[:dataset_name]
            }
          end

          {
            items: items,
            total_count: pages.count,
            current_page: pages.page,
            per_page: pages.items,
            total_pages: pages.pages
          }
        end

      end
    end
  end
end
