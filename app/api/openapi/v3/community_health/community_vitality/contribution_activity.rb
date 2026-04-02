# frozen_string_literal: true

module Openapi
  module V3
    module CommunityHealth
      module CommunityVitality
        class ContributionActivity < Grape::API
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

          resource :contribution_activity do
            desc '代码提交次数 / Commit Count',
                 detail: 'Total number of new commits during the period / 周期内新增的Commit总数',
                 tags: [
                   'V3 API',
                   'Metrics / 度量指标',
                   'Community Ecosystem Health / 社区生态健康评估'
                 ],
                 success: { code: 201, model: Openapi::Entities::CommitCountMetricResponse }
            params { use :metric_search }
            post :commit_count do
              fetch_metric_data_v2(ContributionActivityMetric, 'commit_count')
            end

            desc 'Lines of Code Change / 新增代码行数 ',
                 detail: 'Total code line changes during the period / 周期内代码行变动总量',
                 tags: [
                   'V3 API',
                   'Metrics / 度量指标',
                   'Community Ecosystem Health / 社区生态健康评估'
                 ],
                 success: { code: 201, model: Openapi::Entities::LinesOfCodeChangeResponse }
            params { use :metric_search }
            post :lines_of_code_change do
              fields = %w[lines_added lines_removed]
              fetch_metric_data_v2(ContributionActivityMetric, fields)
            end

            desc 'PR Comment Count / PR 评论数量',
                 detail: 'The total number of comments on all Issues and PRs generated during the period / 周期内产生的所有Issue和PR下的评论总和',
                 tags: [
                   'V3 API',
                   'Metrics / 度量指标',
                   'Community Ecosystem Health / 社区生态健康评估'
                 ],
                 success: { code: 201, model: Openapi::Entities::PrCommentCountResponse }
            params { use :metric_search }
            post :pr_comment_count do
              fetch_metric_data_v2(ContributionActivityMetric, 'pr_comment_count')
            end

            desc 'New Issue Count / Issue 建立数量',
                 detail: 'Total number of issues created during the period / 周期内创建的Issue总数 ',
                 tags: [
                   'V3 API',
                   'Metrics / 度量指标',
                   'Community Ecosystem Health / 社区生态健康评估'
                 ],
                 success: { code: 201, model: Openapi::Entities::NewIssueCountResponse }
            params { use :metric_search }
            post :new_issue_count do
              fetch_metric_data_v2(ContributionActivityMetric, 'issue_new_count')
            end

            desc 'Issue Comment Count / Issue 评论数量',
                 detail: 'Total number of comments under Issues during the period / 周期内Issue下的评论总数',
                 tags: [
                   'V3 API',
                   'Metrics / 度量指标',
                   'Community Ecosystem Health / 社区生态健康评估'
                 ],
                 success: { code: 201, model: Openapi::Entities::IssueCommentCountResponse }
            params { use :metric_search }
            post :issue_comment_count do
              fetch_metric_data_v2(ContributionActivityMetric, 'issue_comment_activity')
            end

            # desc '版本迭代次数 / Release Count',
            #      detail: '周期内发布的Release数量。输入：周期内发布的Release详情。输出：次数（次）。',

            #      success: { code: 201, model: Openapi::Entities::ReleaseCountResponse }
            # params { use :metric_search }
            # post :release_count do
            #   fetch_metric_data(metric_name: 'recent_releases_count')
            # end

            desc 'Contribution Activity Model Data / 贡献活跃度模型数据',
                 detail: "
| 接口名称 | 地址 | 阈值 | 权重 |
|---------|------|------|------|
| 代码提交次数 / Commit Count | /api/v3/contribution_activity/commit_count | 12850 | 0.20 |
| Lines of Code Change / 新增代码行数  | /api/v3/contribution_activity/lines_of_code_change | 300000 | 0.20 |
| PR Comment Count / PR 评论数量 | /api/v3/contribution_activity/pr_comment_count | 10 | 0.20 |
| New Issue Count / Issue 建立数量 | /api/v3/contribution_activity/new_issue_count | 10 | 0.20 |
| Issue Comment Count / Issue 评论数量 | /api/v3/contribution_activity/issue_comment_count | 10 | 0.20 |
",
                 tags: [
                   'V3 API',
                   'Evaluation Model / 评估模型',
                   'Community Ecosystem Health / 社区生态健康评估',
                   'Community Vitality / 社区活力'
                 ],
                 success: { code: 201, model: Openapi::Entities::ContributionActivityModelDataResponse }
            params { use :metric_search }
            post :model_data do
              fields = %w[commit_count lines_added lines_removed pr_comment_count issue_new_count issue_comment_activity score]
              fetch_metric_data_v2(ContributionActivityMetric, fields)
            end
          end
        end
      end
    end
  end
end
