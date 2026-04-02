# frozen_string_literal: true
module Openapi
  module V3
    module CommunityHealth
      module CollaborationEfficiency

        class ResponseTimeliness < Grape::API

          version 'v3', using: :path
          prefix :api
          format :json

          helpers Openapi::SharedParams::CustomMetricSearch
          helpers Openapi::SharedParams::AuthHelpers
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

          before { require_token! }
          before do
            token = params[:access_token]
            Openapi::SharedParams::RateLimiter.check_token!(token)
          end
          before { save_tracking_api! }

          resource :response_timeliness do
            desc 'Issue Unresponsive Rate / Issue 未响应占比',
                 detail: 'Percentage of new issues created in the target cycle that still have no human response after > 1 cycle (excluding bot and issue author comments) / 当前周期新建Issue超过一个周期未响应的占比，不包括机器人、创建者评论。',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Community Ecosystem Health / 社区生态健康评估',
                   'Collaboration Efficiency / 协作效率',
                   'Response Timeliness / 响应及时性'
                 ],
                 success: {
                   code: 201, model: Openapi::Entities::IssueUnresponsiveRateResponse
                 }
            params { use :metric_search }
            post :issue_unresponsive_rate do
              fetch_metric_data_v2(ResponseTimelinessMetric, 'issue_new_unresponsive_ratio')
            end

            desc 'Issue First Response Time / Issue 首次响应时间',
                 detail: 'Time interval from issue creation to first human response within the cycle (excluding bot and issue author comments). Output: avg/median / 新建Issue周期内首次响应时间，不包括机器人、创建者评论，输出平均/中位数。',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Community Ecosystem Health / 社区生态健康评估',
                   'Collaboration Efficiency / 协作效率',
                   'Response Timeliness / 响应及时性'
                 ],
                 success: {
                   code: 201, model: Openapi::Entities::IssueFirstResponseTimeResponse
                 }
            params { use :metric_search }
            post :issue_first_reponse do
              fields = %w[issue_new_first_response_avg issue_new_first_response_mid]
              fetch_metric_data_v2(ResponseTimelinessMetric, fields)
            end

            desc 'Issue Processing Time / Issue 处理时长',
                 detail: 'Average/median time (days) from issue creation to close, or to cycle start time if still open / Issue处理时长均值（天），包含已关闭与未解决：关闭时间-创建时间；未关闭：周期开始时间-创建时间。',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Community Ecosystem Health / 社区生态健康评估',
                   'Collaboration Efficiency / 协作效率',
                   'Response Timeliness / 响应及时性'
                 ],
                 success: {
                   code: 201, model: Openapi::Entities::IssueOpenTimeResponse
                 }
            params { use :metric_search }
            post :issue_open_time do
              fields = %w[issue_new_handle_time_avg issue_new_handle_time_mid]
              fetch_metric_data_v2(ResponseTimelinessMetric, fields)
            end

            # PR
            desc 'PR Unresponsive Rate / PR 未响应占比',
                 detail: 'Percentage of new PRs created in the target cycle that still have no response after > 1 cycle / 当前周期新建PR超过一个周期未响应的占比。',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Community Ecosystem Health / 社区生态健康评估',
                   'Collaboration Efficiency / 协作效率',
                   'Response Timeliness / 响应及时性'
                 ],
                 success: {
                   code: 201, model: Openapi::Entities::PrUnresponsiveRateResponse
                 }
            params { use :metric_search }
            post :pr_unresponsive_rate do
              fetch_metric_data(metric_name: 'pr_unresponsive_rate')
            end

            desc 'PR First Response Time / PR 首次响应时间',
                 detail: 'Time interval from PR creation to first human response within the cycle (excluding bot and PR author comments). Output: avg/median / 新建PR周期内首次响应时间，不包括机器人、创建者评论，输出平均/中位数。',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Community Ecosystem Health / 社区生态健康评估',
                   'Collaboration Efficiency / 协作效率',
                   'Response Timeliness / 响应及时性'
                 ],
                 success: {
                   code: 201, model: Openapi::Entities::PrFirstResponseTimeResponse
                 }
            params { use :metric_search }
            post :pr_time_to_first_response do
              fields = %w[pr_new_first_response_avg pr_new_first_response_mid]
              fetch_metric_data_v2(ResponseTimelinessMetric, fields)
            end

            desc 'PR Processing Time / PR 处理时长',
                 detail: 'Average/median time (days) from PR creation to merge/close, or to cycle start time if still open / PR从创建到合并或关闭的时长（天）：关闭时间-创建时间；未关闭：周期开始时间-创建时间。',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Community Ecosystem Health / 社区生态健康评估',
                   'Collaboration Efficiency / 协作效率',
                   'Response Timeliness / 响应及时性'
                 ],
                 success: {
                   code: 201, model: Openapi::Entities::PrHandleTimeResponse
                 }
            params { use :metric_search }
            post :pr_open_time do
              fields = %w[pr_new_handle_time_avg pr_new_handle_time_mid]
              fetch_metric_data_v2(ResponseTimelinessMetric, fields)
            end
          end

        end
      end
    end
  end
end
