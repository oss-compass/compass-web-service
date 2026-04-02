# frozen_string_literal: true


module Openapi
  module V3
    module DeveloperJourney
      module DeveloperGrowth
        class ParticipationTier < Grape::API
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

          resource :participation_tier do
            desc 'Org Code Core Contributors / 组织代码核心开发者（含管理者）数量',
                 detail: 'Count of org contributors whose code share is above 50% in the period / 本周期内代码贡献占比大于总代码贡献量50%的组织贡献者数量',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Developer Journey / 开发者旅程评估',
                   'Developer Growth / 开发者成长',
                   'Participation Tier / 开发者参与度分层'
                 ],
                 success: { code: 201, model: Openapi::Entities::ParticipationTierOrgCodeCoreContributorsResponse }
            params { use :metric_search }
            post :org_code_core_contributors do
              fetch_metric_data_v2(ParticipationTierMetric, 'org_code_core_contributors')
            end

            desc 'Org Issue Core Contributors / 组织Issue核心开发者（含管理者）数量',
                 detail: 'Count of org members in top 50% by Issue activity in the period / 本周期内Issue活跃度排名靠前（前50%）的组织成员数量',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Developer Journey / 开发者旅程评估',
                   'Developer Growth / 开发者成长',
                   'Participation Tier / 开发者参与度分层'
                 ],
                 success: { code: 201, model: Openapi::Entities::ParticipationTierOrgIssueCoreContributorsResponse }
            params { use :metric_search }
            post :org_issue_core_contributors do
              fetch_metric_data_v2(ParticipationTierMetric, 'org_issue_core_contributors')
            end

            desc 'Org Code Regular Contributors / 组织代码常客开发者数量',
                 detail: 'Count of org members with sustained code contribution between core and visitor thresholds (20%-50%) / 本周期内代码贡献占比20%-50%的组织成员数量',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Developer Journey / 开发者旅程评估',
                   'Developer Growth / 开发者成长',
                   'Participation Tier / 开发者参与度分层'
                 ],
                 success: { code: 201, model: Openapi::Entities::ParticipationTierOrgCodeRegularContributorsResponse }
            params { use :metric_search }
            post :org_code_regular_contributors do
              fetch_metric_data_v2(ParticipationTierMetric, 'org_code_regular_contributors')
            end

            desc 'Org Issue Regular Contributors / 组织Issue常客开发者数量',
                 detail: 'Count of org members with sustained Issue activity below core tier / 本周期内有持续Issue互动但未达到核心标准的组织成员数量',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Developer Journey / 开发者旅程评估',
                   'Developer Growth / 开发者成长',
                   'Participation Tier / 开发者参与度分层'
                 ],
                 success: { code: 201, model: Openapi::Entities::ParticipationTierOrgIssueRegularContributorsResponse }
            params { use :metric_search }
            post :org_issue_regular_contributors do
              fetch_metric_data_v2(ParticipationTierMetric, 'org_issue_regular_contributors')
            end

            desc 'Org Code Visitor Contributors / 组织代码访客开发者数量',
                 detail: 'Count of org members with low code share (below 20%) / 本周期内代码贡献占比小于20%的组织成员数量',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Developer Journey / 开发者旅程评估',
                   'Developer Growth / 开发者成长',
                   'Participation Tier / 开发者参与度分层'
                 ],
                 success: { code: 201, model: Openapi::Entities::ParticipationTierOrgCodeVisitorContributorsResponse }
            params { use :metric_search }
            post :org_code_visitor_contributors do
              fetch_metric_data_v2(ParticipationTierMetric, 'org_code_visitor_contributors')
            end

            desc 'Org Issue Visitor Contributors / 组织Issue访客开发者数量',
                 detail: 'Count of org members with low Issue activity / 本周期内仅有偶然Issue互动的组织成员数量',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Developer Journey / 开发者旅程评估',
                   'Developer Growth / 开发者成长',
                   'Participation Tier / 开发者参与度分层'
                 ],
                 success: { code: 201, model: Openapi::Entities::ParticipationTierOrgIssueVisitorContributorsResponse }
            params { use :metric_search }
            post :org_issue_visitor_contributors do
              fetch_metric_data_v2(ParticipationTierMetric, 'org_issue_visitor_contributors')
            end

            desc 'Individual Code Core Contributors / 个人代码核心开发者（含管理者）数量',
                 detail: 'Count of individual developers in top 50% by code contribution in the period / 本周期内代码贡献度排名靠前（前50%）的个人开发者数量',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Developer Journey / 开发者旅程评估',
                   'Developer Growth / 开发者成长',
                   'Participation Tier / 开发者参与度分层'
                 ],
                 success: { code: 201, model: Openapi::Entities::ParticipationTierIndividualCodeCoreContributorsResponse }
            params { use :metric_search }
            post :individual_code_core_contributors do
              fetch_metric_data_v2(ParticipationTierMetric, 'individual_code_core_contributors')
            end

            desc 'Individual Issue Core Contributors / 个人Issue核心开发者（含管理者）数量',
                 detail: 'Count of individual developers in top 50% by Issue activity in the period / 本周期内Issue活跃度排名靠前（前50%）的个人开发者数量',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Developer Journey / 开发者旅程评估',
                   'Developer Growth / 开发者成长',
                   'Participation Tier / 开发者参与度分层'
                 ],
                 success: { code: 201, model: Openapi::Entities::ParticipationTierIndividualIssueCoreContributorsResponse }
            params { use :metric_search }
            post :individual_issue_core_contributors do
              fetch_metric_data_v2(ParticipationTierMetric, 'individual_issue_core_contributors')
            end

            desc 'Individual Code Regular Contributors / 个人代码常客开发者数量',
                 detail: 'Count of individual developers with mid-tier code contribution (20%-50%) / 本周期内代码贡献处于中间层级的个人开发者数量',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Developer Journey / 开发者旅程评估',
                   'Developer Growth / 开发者成长',
                   'Participation Tier / 开发者参与度分层'
                 ],
                 success: { code: 201, model: Openapi::Entities::ParticipationTierIndividualCodeRegularContributorsResponse }
            params { use :metric_search }
            post :individual_code_regular_contributors do
              fetch_metric_data_v2(ParticipationTierMetric, 'individual_code_regular_contributors')
            end

            desc 'Individual Issue Regular Contributors / 个人Issue常客开发者数量',
                 detail: 'Count of individual developers with mid-tier Issue contribution (20%-50%) / 本周期内Issue贡献量处于中间层级（20%-50%）的个人开发者数量',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Developer Journey / 开发者旅程评估',
                   'Developer Growth / 开发者成长',
                   'Participation Tier / 开发者参与度分层'
                 ],
                 success: { code: 201, model: Openapi::Entities::ParticipationTierIndividualIssueRegularContributorsResponse }
            params { use :metric_search }
            post :individual_issue_regular_contributors do
              fetch_metric_data_v2(ParticipationTierMetric, 'individual_issue_regular_contributors')
            end

            desc 'Individual Code Visitor Contributors / 个人代码访客开发者数量',
                 detail: 'Count of individual developers with low/single code contribution (below 20%) / 本周期内代码贡献为低频/单次（小于20%）的个人开发者数量',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Developer Journey / 开发者旅程评估',
                   'Developer Growth / 开发者成长',
                   'Participation Tier / 开发者参与度分层'
                 ],
                 success: { code: 201, model: Openapi::Entities::ParticipationTierIndividualCodeVisitorContributorsResponse }
            params { use :metric_search }
            post :individual_code_visitor_contributors do
              fetch_metric_data_v2(ParticipationTierMetric, 'individual_code_visitor_contributors')
            end

            desc 'Individual Issue Visitor Contributors / 个人Issue访客开发者数量',
                 detail: 'Count of individual developers with low/single Issue contribution (below 20%) / 本周期内Issue贡献量低频/单次（小于20%）的个人开发者数量',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Developer Journey / 开发者旅程评估',
                   'Developer Growth / 开发者成长',
                   'Participation Tier / 开发者参与度分层'
                 ],
                 success: { code: 201, model: Openapi::Entities::ParticipationTierIndividualIssueVisitorContributorsResponse }
            params { use :metric_search }
            post :individual_issue_visitor_contributors do
              fetch_metric_data_v2(ParticipationTierMetric, 'individual_issue_visitor_contributors')
            end
          end
        end
      end
    end
  end
end
