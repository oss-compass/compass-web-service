# frozen_string_literal: true

module Openapi
  module V3
    module CollaborationEfficiency
      class ResponseTimelinessMetricsModel < Grape::API

        version 'v3', using: :path
        prefix :api
        format :json

        helpers Openapi::SharedParams::Search
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

        resource :responseTimelinessMetrics do

          # Issue
          desc 'Issue Unresponsive Rate / Issue 未响应占比',
               detail: 'Percentage of new issues created in the target cycle that still have no human response after > 1 cycle (excluding bot and issue author comments) / 当前周期新建Issue超过一个周期未响应的占比，不包括机器人、创建者评论。',
               tags: ['Metrics Data / 指标数据', 'Collaboration Quality Metrics / 协作质量指标'],
               success: {
                 code: 201, model: Openapi::Entities::IssueUnresponsiveRateResponse
               }
          params { use :community_portrait_search }
          post :issue_unresponsive_rate do
            fetch_metric_data(metric_name: 'issue_unresponsive_rate')
          end

          desc 'Issue First Response Time / Issue 首次响应时间',
               detail: 'Time interval from issue creation to first human response within the cycle (excluding bot and issue author comments). Output: avg/median / 新建Issue周期内首次响应时间，不包括机器人、创建者评论，输出平均/中位数。',
               tags: ['Metrics Data / 指标数据', 'Collaboration Quality Metrics / 协作质量指标'],
               success: {
                 code: 201, model: Openapi::Entities::IssueFirstResponseResponse
               }
          params { use :community_portrait_search }
          post :issue_first_reponse do
            fetch_metric_data(metric_name: 'issue_first_reponse')
          end

          desc 'Issue Processing Time / Issue 处理时长',
               detail: 'Average/median time (days) from issue creation to close, or to cycle start time if still open / Issue处理时长均值（天），包含已关闭与未解决：关闭时间-创建时间；未关闭：周期开始时间-创建时间。',
               tags: ['Metrics Data / 指标数据', 'Collaboration Quality Metrics / 协作质量指标'],
               success: {
                 code: 201, model: Openapi::Entities::IssueOpenTimeResponse
               }
          params { use :community_portrait_search }
          post :issue_open_time do
            fetch_metric_data(metric_name: 'issue_open_time')
          end

          # PR
          desc 'PR Unresponsive Rate / PR 未响应占比',
               detail: 'Percentage of new PRs created in the target cycle that still have no response after > 1 cycle / 当前周期新建PR超过一个周期未响应的占比。',
               tags: ['Metrics Data / 指标数据', 'Collaboration Quality Metrics / 协作质量指标'],
               success: {
                 code: 201, model: Openapi::Entities::PrUnresponsiveRateResponse
               }
          params { use :community_portrait_search }
          post :pr_unresponsive_rate do
            fetch_metric_data(metric_name: 'pr_unresponsive_rate')
          end

          desc 'PR First Response Time / PR 首次响应时间',
               detail: 'Time interval from PR creation to first human response within the cycle (excluding bot and PR author comments). Output: avg/median / 新建PR周期内首次响应时间，不包括机器人、创建者评论，输出平均/中位数。',
               tags: ['Metrics Data / 指标数据', 'Collaboration Quality Metrics / 协作质量指标'],
               success: {
                 code: 201, model: Openapi::Entities::PrTimeToFirstResponseResponse
               }
          params { use :community_portrait_search }
          post :pr_time_to_first_response do
            fetch_metric_data(metric_name: 'pr_time_to_first_response')
          end

          desc 'PR Processing Time / PR 处理时长',
               detail: 'Average/median time (days) from PR creation to merge/close, or to cycle start time if still open / PR从创建到合并或关闭的时长（天）：关闭时间-创建时间；未关闭：周期开始时间-创建时间。',
               tags: ['Metrics Data / 指标数据', 'Collaboration Quality Metrics / 协作质量指标'],
               success: {
                 code: 201, model: Openapi::Entities::PrOpenTimeResponse
               }
          params { use :community_portrait_search }
          post :pr_open_time do
            fetch_metric_data(metric_name: 'pr_open_time')
          end

        end
      end
    end
  end
end
