# frozen_string_literal: true

module Openapi
  module V3
    module CommunityHealth

      module CollaborationEfficiency
        class CollaborationQuality < Grape::API
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

          resource :collaboration_quality do

            desc 'PR Merge Rate / PR 合并率',
                 detail: 'Ratio of PRs created in cycle-2 that are ultimately merged / 周期内新建并最终被合并的PR占比。',
                 tags: [
                   'V3 API',
                   'Metrics / 度量指标',
                   'Community Ecosystem Health / 社区生态健康评估'
                 ],
                 success: { code: 201, model: Openapi::Entities::PrMergeRateResponse }
            params { use :metric_search }
            post :pr_merge_rate do
              fields = %w[pr_merge_ratio pr_merged_count pr_total_count]
              fetch_metric_data_v2(CollaborationQualityMetric, fields)
            end

            desc 'PR/Issue Link Rate / PR/Issue 关联率',
                 detail: 'Ratio of PRs linked to an Issue in cycle-2 / 周期内 PR关联Issue的占比。',
                 tags: [
                   'V3 API',
                   'Metrics / 度量指标',
                   'Community Ecosystem Health / 社区生态健康评估'
                 ],
                 success: { code: 201, model: Openapi::Entities::PrIssueLinkRateResponse }
            params { use :metric_search }
            post :pr_issue_link_rate do
              fields = %w[pr_issue_linked_ratio pr_issue_linked_count pr_total_count]
              fetch_metric_data_v2(CollaborationQualityMetric, fields)
            end

            desc 'PR Review Participation Rate / PR 评审参与率',
                 detail: 'Ratio of PRs that have at least one non-author review comment or approval in cycle-2 / 周期内至少有一条非作者Review评论或Approval记录的PR占比。',
                 tags: [
                   'V3 API',
                   'Metrics / 度量指标',
                   'Community Ecosystem Health / 社区生态健康评估'
                 ],
                 success: { code: 201, model: Openapi::Entities::PrReviewParticipationRateResponse }
            params { use :metric_search }
            post :pr_review_participation_rate do
              fields = %w[pr_review_participation_ratio pr_with_review_count pr_total_count]
              fetch_metric_data_v2(CollaborationQualityMetric, fields)
            end

            desc 'Non-author Merge Rate / Merge协作比率',
                 detail: 'Ratio of merged PRs whose merger is not the author in cycle-2 / 周期内PR的合并操作者与PR提交者不是同一人的比例。',
                 tags: [
                   'V3 API',
                   'Metrics / 度量指标',
                   'Community Ecosystem Health / 社区生态健康评估'
                 ],
                 success: { code: 201, model: Openapi::Entities::PrNonAuthorMergeRateResponse }
            params { use :metric_search }
            post :pr_non_author_merge_rate do
              fields = %w[pr_non_author_merge_ratio pr_non_author_merged_count pr_merged_total_count]
              fetch_metric_data_v2(CollaborationQualityMetric, fields)
            end

            desc 'PR Average Interactions / PR 平均交互数',
                 detail: 'Average number of conversation/comments per PR (excluding bot comments) / 平均每个PR下的对话/评论数量。',
                 tags: [
                   'V3 API',
                   'Metrics / 度量指标',
                   'Community Ecosystem Health / 社区生态健康评估'
                 ],
                 success: { code: 201, model: Openapi::Entities::PrAverageInteractionsResponse }
            params { use :metric_search }
            post :pr_average_interactions do
              fields = %w[pr_avg_interactions pr_comments_total pr_total_count]
              fetch_metric_data_v2(CollaborationQualityMetric, fields)
            end

            desc 'Review Time by Pull Request Size / 分级代码审查时长',
                 detail: 'average review time grouped by PR size (XS/S/M/L/XL) / 按代码变更行数分组统计的平均审查时间。',
                 tags: [
                   'V3 API',
                   'Metrics / 度量指标',
                   'Community Ecosystem Health / 社区生态健康评估'
                 ],
                 success: { code: 201, model: Openapi::Entities::PrReviewTimeBySizeResponse }
            params { use :metric_search }
            post :pr_review_time_by_size do
              fetch_metric_data_v2(CollaborationQualityMetric, 'pr_review_time_by_size')
            end

            desc 'Collaboration Quality Model Data / 协作开发质量模型数据',
                 detail: "
| 接口名称 | 地址 | 阈值 | 权重 |
|---------|------|------|------|
| PR Merge Rate / PR 合并率 | /api/v3/collaboration_quality/pr_merge_rate | 1 | 0.17 |
| PR/Issue Link Rate / PR/Issue 关联率 | /api/v3/collaboration_quality/pr_issue_link_rate | 1 | 0.17 |
| PR Review Participation Rate / PR 评审参与率 | /api/v3/collaboration_quality/pr_review_participation_rate | 1 | 0.17 |
| Non-author Merge Rate / Merge协作比率 | /api/v3/collaboration_quality/pr_non_author_merge_rate | 1 | 0.17 |
| PR Average Interactions / PR 平均交互数 | /api/v3/collaboration_quality/pr_average_interactions | 1 | 0.17 |
| Review Time by Pull Request Size / 分级代码审查时长 | /api/v3/collaboration_quality/pr_review_time_by_size | 10 | 0.17 |
",
                 tags: [
                   'V3 API',
                   'Evaluation Model / 评估模型',
                   'Community Ecosystem Health / 社区生态健康评估',
                   'Collaboration Efficiency / 协作效率'
                 ],
                 success: { code: 201, model: Openapi::Entities::CollaborationQualityModelDataResponse }
            params { use :metric_search }
            post :model_data do
              fields = %w[pr_merge_ratio pr_merged_count pr_total_count pr_issue_linked_ratio pr_issue_linked_count pr_review_participation_ratio pr_with_review_count pr_non_author_merge_ratio pr_non_author_merged_count pr_merged_total_count pr_avg_interactions pr_comments_total pr_review_time_by_size score]
              fetch_metric_data_v2(CollaborationQualityMetric, fields)
            end
          end
        end
      end
    end
  end
end
