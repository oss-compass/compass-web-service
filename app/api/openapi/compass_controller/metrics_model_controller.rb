# frozen_string_literal: true

module Openapi
  module CompassController

    class MetricsModelController < Grape::API

      # version 'compass', using: :path
      prefix :services
      format :json

      helpers Openapi::SharedParams::CustomMetricSearch

      helpers Openapi::V1::Helpers
      helpers Openapi::SharedParams::ErrorHelpers
      helpers Openapi::SharedParams::RestapiHelpers

      # rescue_from :all do |e|
      #   case e
      #   when Grape::Exceptions::ValidationErrors
      #     handle_validation_error(e)
      #   when SearchFlip::ResponseError
      #     handle_open_search_error(e)
      #   else
      #     handle_generic_error(e)
      #   end
      # end

      helpers do
        include Pagy::Backend

        def paginate_fun(scope)
          pagy(scope, page: params[:page], items: params[:per_page])
        end

      end

      # before { require_login! }

      resource :metrics_model_v2 do
        helpers do

          def fetch_metric_response(indexer, params)
            label, level, filter_opts, sort_opts, begin_date, end_date, page, size = extract_search_model_params!(params)

            repo_urls = [label]

            resp = indexer.terms_by_metric_repo_urls(
              repo_urls, begin_date, end_date,
              per: size, page: page,
              filter_opts: filter_opts, sort_opts: sort_opts
            )

            count = indexer.count_by_metric_repo_urls(repo_urls, begin_date, end_date, filter_opts: filter_opts)

            hits = resp&.dig('hits', 'hits') || []
            items = hits.map { |data| data['_source'].symbolize_keys }

            {
              count: count,
              total_page: (count.to_f / (size || 10)).ceil,
              page: page,
              items: items
            }
          end
        end

        desc '获取项目响应及时性 (Response Timeliness)', tags: ['Metrics Model Data V2']
        params { use :search_model }
        post :response_timeliness do
          # 对应 index: compass_metric_model_v2_response_timeliness
          fetch_metric_response(ResponseTimelinessMetric, params)
        end

        desc '获取协作开发质量 (Collaboration Quality)', tags: ['Metrics Model Data V2']
        params { use :search_model }
        post :collaboration_quality do
          # 对应 index: compass_metric_model_v2_collaboration_quality
          fetch_metric_response(CollaborationQualityMetric, params)
        end

        desc '获取开发者基数 (Developer Base)', tags: ['Metrics Model Data V2']
        params { use :search_model }
        post :developer_base do
          # 对应 index: compass_metric_model_v2_developer_base
          fetch_metric_response(DeveloperBaseMetric, params)
        end

        desc '获取贡献活跃度 (Contribution Activity)', tags: ['Metrics Model Data V2']
        params { use :search_model }
        post :contribution_activity do
          # 对应 index: compass_metric_model_v2_contribution_activity
          fetch_metric_response(ContributionActivityMetric, params)
        end

        desc '获取社区流行度 (Community Popularity)', tags: ['Metrics Model Data V2']
        params { use :search_model }
        post :community_popularity do
          # 对应 index: compass_metric_model_v2_community_popularity
          fetch_metric_response(CommunityPopularityMetric, params)
        end

        desc '获取组织开放治理 (Organizational Governance)', tags: ['Metrics Model Data V2']
        params { use :search_model }
        post :organizational_governance do
          # 对应 index: compass_metric_model_v2_organizational_governance
          fetch_metric_response(OrganizationalGovernanceMetric, params)
        end

        desc '获取个人开放治理 (Personal Governance)', tags: ['Metrics Model Data V2']
        params { use :search_model }
        post :personal_governance do
          # 对应 index: compass_metric_model_v2_personal_governance
          fetch_metric_response(PersonalGovernanceMetric, params)
        end
      end
    end
  end
end

