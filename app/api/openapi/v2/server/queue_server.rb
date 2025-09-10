# frozen_string_literal: true

module Openapi
  module V2
    module Server
      class QueueServer < Grape::API
        version 'v2', using: :path
        prefix :api
        format :json

        DEFAULT_HOST = ENV.fetch('DEFAULT_HOST')
        TPC_SERVICE_CALLBACK_URL = "#{DEFAULT_HOST}/api/tpc_software_callback"

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

        resource :queue_server do

          desc '队列列表', hidden: true, tags: ['admin'], success: {
            code: 200
          }, detail: '返回每个队列类型最新一条数据'

          post :queue_list do

            types = ["repo", "repo_high_priority", "group", "group_high_priority"]

            result = types.map do |type|
              m = MqMetric.where(queue_type: type)
                          .order(created_at: :desc)
                          .first
              next unless m

              {
                queue_type: type,
                queue: m.queue_name,
                total: m.total,
                ready: m.ready,
                unacknowledged: m.unacknowledged,
                consumers: m.consumers,
                belong_to: m.belong_to
              }
            end.compact

            result
          end

          desc 'tpc队列消息数量', hidden: true, tags: ['admin'], success: {
            code: 200
          }, detail: 'pc队列消息数量'

          post :tpc_queue_list do
            types = ["tpc", "tpc_high_priority"]

            result = types.map do |type|
              m = MqMetric.where(queue_type: type)
                          .order(created_at: :desc)
                          .first
              next unless m

              {
                queue_type: type,
                queue: m.queue_name,
                total: m.total,
                ready: m.ready,
                unacknowledged: m.unacknowledged,
                consumers: m.consumers,
                belong_to: m.belong_to
              }
            end.compact

            result
          end

          desc '加入普通队列/优先队列', hidden: true, tags: ['admin'], success: {
            code: 200
          }, detail: '加入优先队列'
          params do
            requires :project_url, type: String, desc: '项目地址', documentation: { param_type: 'body' }
            requires :type, type: Integer, desc: '类型，0普通队列，1优先队列', documentation: { param_type: 'body' }
          end
          post :add_queue do
            type = params[:type]
            project_url = params[:project_url]
            server = AnalyzeServer.new({ repo_url: project_url })
            result = if type == 0
                       server.execute_workflow
                     else
                       server.execute_high_priority
                     end

            result
          end

          desc '多个项目加入普通队列/优先队列', hidden: true, tags: ['admin'], success: {
            code: 200
          }, detail: '多个项目加入普通队列/优先队列'
          params do
            requires :project_urls, type: Array[String], desc: '项目地址', documentation: { param_type: 'body' }
            requires :type, type: Integer, desc: '类型，0普通队列，1优先队列', documentation: { param_type: 'body' }
          end
          post :projects_add_queue do
            type = params[:type]

            project_urls = params[:project_urls]

            results = project_urls.map do |project_url|
              server = AnalyzeServer.new({ repo_url: project_url })
              if type == 0
                server.execute_workflow
              else
                server.execute_high_priority
              end
            end

            { result: results }
          end

          desc '社区加入普通队列/优先队列', hidden: true, tags: ['admin'], success: {
            code: 200
          }, detail: '社区加入普通队列/优先队列'
          params do
            requires :community_name, type: String, desc: '社区名称', documentation: { param_type: 'body' }
            requires :type, type: Integer, desc: '类型，0普通队列，1优先队列', documentation: { param_type: 'body' }
          end
          post :add_group_queue do
            type = params[:type]
            label = params[:community_name]

            task = ProjectTask.find_by(project_name: label)
            raise '该社区不存在' unless task

            server = AnalyzeGroupServer.new(yaml_url: task.remote_url)
            result = if type == 0
                       server.execute_workflow
                     else
                       server.execute_high_priority
                     end

            result
          end

          desc '加入tpc普通队列/优先队列', hidden: true, tags: ['admin'], success: {
            code: 200
          }, detail: '加入tpc优先队列'
          params do
            requires :report_id, type: String, desc: '报告ID', documentation: { param_type: 'body' }
            requires :report_type, type: Integer, desc: '报告类型 0孵化，1毕业', documentation: { param_type: 'body' }
            requires :type, type: Integer, desc: '类型，0普通队列，1优先队列', documentation: { param_type: 'body' }

          end
          post :add_tpc_queue do
            report_id = params[:report_id]
            report_type = params[:report_type]
            type = params[:type]

            if report_type == 0
              metric = TpcSoftwareReportMetric.find_by(tpc_software_report_id: report_id)
            else
              metric = TpcSoftwareGraduationReportMetric.find_by(tpc_software_graduation_report_id: report_id)
            end

            report_metric_id = metric[:id]
            project_url = metric[:code_url]

            server = AnalyzeServer.new(
              {
                repo_url: project_url,
                callback: {
                  hook_url: TPC_SERVICE_CALLBACK_URL,
                  params: {
                    callback_type: "tpc_software_callback",
                    task_metadata: {
                      report_id: report_id,
                      report_metric_id: report_metric_id,
                      report_type: report_type
                    }
                  }
                }
              }
            )

            result = if type == 0
                       server.execute_tpc
                     else
                       server.execute_tpc_high_priority
                     end

            result
          end

          desc '仓库、社区 队列图表', hidden: true, tags: ['admin'], success: {
            code: 200
          }, detail: '队列图表'
          params do
            requires :begin_date, type: DateTime, desc: '开始日期', documentation: { param_type: 'body', example: '2010-02-22' }
            requires :end_date, type: DateTime, desc: '结束日期', documentation: { param_type: 'body', example: '2026-03-22' }
            optional :queue_type, type: String, desc: '队列类型:repo,repo_high_priority,group,group_high_priority ', documentation: { param_type: 'body', example: 0 }
            requires :is_all, type: Integer, desc: '0否 1全部队列', documentation: { param_type: 'body', example: 0 }
          end
          post :queue_table do
            begin_date = params[:begin_date]
            end_date = params[:end_date]
            queue_type = params[:queue_type]

            is_all = params[:is_all]

            types =
              if is_all == 1
                ["repo", "repo_high_priority", "group", "group_high_priority"]
              else
                [queue_type]
              end

            metrics = MqMetric.where(created_at: begin_date..end_date, queue_type: types)
                              .order(:created_at)

            data =
              if is_all == 1
                metrics.group_by { |m| m.created_at.strftime("%Y-%m-%d %H:%M:%S") }
                       .map do |time, records|
                  {
                    created_at: time,
                    join_count: records.sum(&:ready),
                    consume_count: records.sum(&:unacknowledged),
                    total_count: records.sum(&:total)
                  }
                end
              else

                metrics.map do |m|
                  {
                    created_at: m.created_at.strftime("%Y-%m-%d %H:%M:%S"),
                    join_count: m.ready,
                    consume_count: m.unacknowledged,
                    total_count: m.total
                  }
                end
              end

            data
          end

          desc 'tpc 队列图表', hidden: true, tags: ['admin'], success: {
            code: 200
          }, detail: '队列图表'
          params do
            requires :begin_date, type: DateTime, desc: '开始日期', documentation: { param_type: 'body', example: '2010-02-22' }
            requires :end_date, type: DateTime, desc: '结束日期', documentation: { param_type: 'body', example: '2026-03-22' }
            requires :queue_type, type: String, desc: '队列类型:tpc,tpc_high_priority', documentation: { param_type: 'body', example: 0 }
            requires :is_all, type: Integer, desc: '0否 1全部队列', documentation: { param_type: 'body', example: 0 }
          end
          post :tpc_queue_table do
            begin_date = params[:begin_date]
            end_date = params[:end_date]
            queue_type = params[:queue_type]
            is_all = params[:is_all]

            types =
              if is_all == 1
                ["tpc", "tpc_high_priority"]
              else
                [queue_type]
              end

            metrics = MqMetric.where(created_at: begin_date..end_date, queue_type: types)
                              .order(:created_at)

            data =
              if is_all == 1
                metrics.group_by { |m| m.created_at.strftime("%Y-%m-%d %H:%M:%S") }
                       .map do |time, records|
                  {
                    created_at: time,
                    join_count: records.sum(&:ready),
                    consume_count: records.sum(&:unacknowledged),
                    total_count: records.sum(&:total)
                  }
                end
              else
                metrics.map do |m|
                  {
                    created_at: m.created_at.strftime("%Y-%m-%d %H:%M:%S"),
                    join_count: m.ready,
                    consume_count: m.unacknowledged,
                    total_count: m.total
                  }
                end
              end

            data

          end

          desc '批量加入普通队列/优先队列', hidden: true, tags: ['admin'], success: {
            code: 200
          }, detail: '批量加入普通队列/优先队列'
          params do
            requires :time_type, type: Integer, desc: '时间类型：1，3，6，12', documentation: { param_type: 'body' }
            requires :queue_type, type: Integer, desc: '类型，0普通队列，1优先队列', documentation: { param_type: 'body' }
          end
          post :batch_add_queue do
            time_type = params[:time_type]
            queue_type = params[:queue_type]

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

            projects = Subject.where(level: 'repo', updated_at: start_time..end_time)

            Thread.new do
              projects.each do |project|
                server = AnalyzeServer.new({ repo_url: project.label })
                if queue_type == 0
                  server.execute_workflow
                else
                  server.execute_high_priority
                end
                sleep(1)
              end

            end

            { message: "已加入#{projects.count}个项目到#{queue_type == 0 ? '普通' : '优先'}队列" }

          end

          desc '社区批量加入普通队列/优先队列', hidden: true, tags: ['admin'], success: {
            code: 200
          }, detail: '社区批量加入普通队列/优先队列'
          params do
            requires :time_type, type: Integer, desc: '时间类型：1，3，6，12', documentation: { param_type: 'body' }
            requires :queue_type, type: Integer, desc: '类型，0普通队列，1优先队列', documentation: { param_type: 'body' }
          end
          post :batch_add_group_queue do
            time_type = params[:time_type]
            queue_type = params[:queue_type]

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

            projects = Subject.where(level: 'community', updated_at: start_time..end_time)

            Thread.new do
              projects.each do |project|

                task = ProjectTask.find_by(project_name: project.label)
                server = AnalyzeGroupServer.new(yaml_url: task.remote_url)
                if type == 0
                  server.execute_workflow
                else
                  server.execute_high_priority
                end
                sleep(1)
              end

            end

            { message: "已加入#{projects.count}个社区到#{queue_type == 0 ? '普通' : '优先'}队列" }

          end

        end
      end
    end
  end
end


