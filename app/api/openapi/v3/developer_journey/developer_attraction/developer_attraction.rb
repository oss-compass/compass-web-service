# frozen_string_literal: true

module Openapi
  module V3
    module DeveloperJourney
      module DeveloperAttraction
        class DeveloperAttraction < Grape::API
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

          resource :developer_attraction do

            desc 'New Org Count / 新增组织数',
                 detail: 'Count of organizations that made their first effective contribution (code or Issue) in the community during the period / 本周期内首次在社区产生有效贡献（代码或Issue）的组织去重数量',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                    'Developer Journey / 开发者旅程评估',
                   'Developer Attraction / 开发者吸引',
                   'Developer Attraction / 开发者吸引'
                 ],
                 success: { code: 201, model: Openapi::Entities::DeveloperAttractionNewOrgCountResponse }
            params { use :metric_search }
            post :new_org_count do
              fetch_metric_data_v2(DeveloperAttractionMetric, 'new_org_count')
            end

            desc 'New Org Code Contributors / 新增组织代码开发者数量',
                 detail: 'Count of org members who made their first code contribution during the period / 本周期内首次产生代码贡献的组织成员数量',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Developer Journey / 开发者旅程评估',
                   'Developer Attraction / 开发者吸引',
                   'Developer Attraction / 开发者吸引'
                 ],
                 success: { code: 201, model: Openapi::Entities::DeveloperAttractionNewOrgCodeContributorsResponse }
            params { use :metric_search }
            post :new_org_code_contributors do
              fetch_metric_data_v2(DeveloperAttractionMetric, 'new_org_code_contributors')
            end

            desc 'New Org Non-code Contributors / 新增组织非代码开发者数量',
                 detail: 'Count of org members who made their first non-code contribution during the period / 本周期内首次产生非代码贡献的组织成员数量',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                   'Developer Journey / 开发者旅程评估',
                   'Developer Attraction / 开发者吸引',
                   'Developer Attraction / 开发者吸引'
                 ],
                 success: { code: 201, model: Openapi::Entities::DeveloperAttractionNewOrgNonCodeContributorsResponse }
            params { use :metric_search }
            post :new_org_non_code_contributors do
              fetch_metric_data_v2(DeveloperAttractionMetric, 'new_org_non_code_contributors')
            end

            desc 'New Individual Code Contributors / 新增个人代码开发者数量',
                 detail: 'Count of individual developers who made their first code contribution during the period / 本周期内首次产生代码贡献的个人开发者数量',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                    'Developer Journey / 开发者旅程评估',
                   'Developer Attraction / 开发者吸引',
                   'Developer Attraction / 开发者吸引'
                 ],
                 success: { code: 201, model: Openapi::Entities::DeveloperAttractionNewIndividualCodeContributorsResponse }
            params { use :metric_search }
            post :new_individual_code_contributors do
              fetch_metric_data_v2(DeveloperAttractionMetric, 'new_individual_code_contributors')
            end

            desc 'New Individual Non-code Contributors / 新增个人非代码开发者数量',
                 detail: 'Count of individual developers who made their first non-code contribution during the period / 本周期内首次产生非代码贡献的个人开发者数量',
                 tags: [
                   'V3 API',
                   'Metrics Data / 指标数据',
                    'Developer Journey / 开发者旅程评估',
                   'Developer Attraction / 开发者吸引',
                   'Developer Attraction / 开发者吸引'
                 ],
                 success: { code: 201, model: Openapi::Entities::DeveloperAttractionNewIndividualNonCodeContributorsResponse }
            params { use :metric_search }
            post :new_individual_non_code_contributors do
              fetch_metric_data_v2(DeveloperAttractionMetric, 'new_individual_non_code_contributors')
            end

            desc 'Developer Attraction Model Data / 开发者吸引模型数据',
                 detail: 'Developer Attraction Model Data / 开发者吸引模型数据',
                 tags: [
                   'V3 API',
                   'Metrics Model Data / 模型数据',
                   'Developer Journey / 开发者旅程评估',
                   'Developer Attraction / 开发者吸引',
                   'Developer Attraction / 开发者吸引'
                 ],
                 success: { code: 201, model: Openapi::Entities::DeveloperAttractionModelDataResponse }
            params { use :metric_search }
            post :model_data do
              fields = %w[new_org_count new_org_code_contributors new_org_non_code_contributors new_individual_code_contributors new_individual_non_code_contributors score]
              fetch_metric_data_v2(DeveloperAttractionMetric, fields)
            end

          end
        end
      end
    end
  end
end
