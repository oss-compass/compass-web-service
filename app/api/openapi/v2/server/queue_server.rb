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

          desc '队列消息数量', hidden: true, tags: ['admin'], success: {
            code: 200
          }, detail: '获取 test_queue 队列消息数量'

          post :queue_list do
            rabbitmq_host = "http://119.8.41.180:9673"
            vhost = "/"
            queue = "test_queue"

            conn = Faraday.new(url: rabbitmq_host) do |f|
              f.adapter Faraday.default_adapter
            end

            username = "admin"
            password = "admin"
            # 构建 Basic Auth Header
            auth_token = Base64.strict_encode64("#{username}:#{password}")
            headers = { "Authorization" => "Basic #{auth_token}" }

            response = conn.get("/api/queues/#{CGI.escape(vhost)}/#{queue}", nil, headers)

            if response.success?
              body = JSON.parse(response.body)
              {
                queue: queue,
                total: body["messages"], # 总消息数
                ready: body["messages_ready"], # 就绪消息数
                unacknowledged: body["messages_unacknowledged"], # 未确认消息数
                consumers: body["consumers"], # 消费者数量
                state: body["state"] # 队列状态
              }
            else
              error!({ error: "Failed to fetch queue info", status: response.status }, 500)
            end
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

        end
      end
    end
  end
end


