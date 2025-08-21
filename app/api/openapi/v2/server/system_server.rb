# frozen_string_literal: true

module Openapi
  module V2
    module Server
      class SystemServer < Grape::API
        version 'v2', using: :path
        prefix :api
        format :json

        before do
          unless request.path.include?('/server/save_data')
            require_login!
          end
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

        resource :server do

          desc '保存系统信息', hidden: true, tags: ['admin'], success: {
            code: 201
          }, detail: '保存系统信息'

          params do
            requires :server_id, type: String, desc: '服务器 ID'
            requires :cpu_percent, type: Float, documentation: { param_type: 'body' }
            requires :memory_percent, type: Float, documentation: { param_type: 'body' }
            requires :disk_percent, type: Float, documentation: { param_type: 'body' }
            requires :disk_io_read, type: Float, documentation: { param_type: 'body' }
            requires :disk_io_write, type: Float, documentation: { param_type: 'body' }
            requires :net_io_recv, type: Float, documentation: { param_type: 'body' }
            requires :net_io_sent, type: Float, documentation: { param_type: 'body' }
          end

          post :save_data do
            ServerMetric.create!(
              server_id: params[:server_id],
              cpu_percent: params[:cpu_percent],
              memory_percent: params[:memory_percent],
              disk_percent: params[:disk_percent],
              disk_io_read: params[:disk_io_read],
              disk_io_write: params[:disk_io_write],
              net_io_recv: params[:net_io_recv],
              net_io_sent: params[:net_io_sent]
            )

            {
              message: 'ok'
            }
          end

          desc '获取服务器列表', hidden: true, tags: ['admin'], success: {
            code: 201
          }, detail: '获取服务器列表'
          params do
            requires :belong_to, type: String, desc: '服务器归属', documentation: { param_type: 'body', example: '中科院' }

          end
          post :list do
            belong_to = params['belong_to']
            servers = ServerInfo.where(belong_to: belong_to)

            # 拼接最新监控数据
            result = servers.map do |server|
              latest_metric = ServerMetric
                                .where(server_id: server.server_id)
                                .order(created_at: :desc)
                                .first

              server.as_json.merge(
                metric: latest_metric
              )
            end

            result
          end

          desc '获取服务器图表', hidden: true, tags: ['admin'], success: {
            code: 201
          }, detail: '获取服务器图表'
          params do
            requires :server_id, type: String, desc: '服务器id', documentation: { param_type: 'body', example: 'worker01' }
            requires :begin_time, type: DateTime, desc: 'Start time',
                     documentation: { param_type: 'body', example: '2025-08-01 02:24:10' }
            requires :end_time, type: DateTime, desc: 'End time',
                     documentation: { param_type: 'body', example: '2025-08-01 03:24:10' }

          end
          post :metric_table do
            server_id = params['server_id']
            begin_time = params['begin_time']
            end_time = params['end_time']
            ServerMetric.where(server_id: server_id).where(created_at: begin_time..end_time).order(created_at: :asc)

          end

          #


          # desc '获取服务器图表', hidden: true, tags: ['admin'], success: {
          #   code: 201
          # }, detail: '获取服务器列表'
          # params do
          #   requires :server_id, type: String, desc: '服务器id', documentation: { param_type: 'body', example: 'worker01' }
          #   requires :begin_time, type: DateTime, desc: 'Start time',
          #            documentation: { param_type: 'body', example: '2025-08-01 02:24:10' }
          #   requires :end_time, type: DateTime, desc: 'End time',
          #            documentation: { param_type: 'body', example: '2025-08-01 03:24:10' }
          #
          # end
          # post :metric_table_te do
          #   server_id = params['server_id']
          #   begin_time = params['begin_time']
          #   end_time = params['end_time']
          #   #
          #   ServerMetric.where(server_id: server_id).where(created_at: begin_time..end_time)
          # end

        end
      end
    end
  end
end

