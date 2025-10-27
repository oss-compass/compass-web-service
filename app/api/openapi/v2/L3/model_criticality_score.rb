# frozen_string_literal: true

module Openapi
  module V2
    module L3
    class ModelCriticalityScore < Grape::API

      version 'v2', using: :path
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
      before { save_tracking_api! }
      resource :metricModel do
        desc 'Get Project Criticality Score /  获取项目 Criticality Score', detail: 'Get Project Criticality Score /  获取项目 Criticality Score', tags: ['Metrics Model Data / 模型数据'], success: {
          code: 201, model: Openapi::Entities::CriticalityScoreResponse
        }

        params {
          requires :access_token, type: String, desc: 'access token / 访问令牌', documentation: { param_type: 'body' }
          requires :label, type: String, desc: 'Repository address / 仓库地址', documentation: { param_type: 'body', example: 'https://github.com/oss-compass/compass-web-service' }
        }
        post :criticality_score do

          indexer = CriticalityScoreMetric
          repo_urls = [params[:label]]

          resp = indexer.one_by_metric_repo_urls(repo_urls)


          hits = resp&.[]('hits')&.[]('hits') || []
          items = hits.map { |data| data['_source'].symbolize_keys }
          items.first || {}
        end


        desc 'Analyze Project Criticality Score / 分析项目 Criticality Score', detail: 'Analyze Project Criticality Score / 分析项目 Criticality Score', tags: ['Metrics Model Data / 模型数据'], success: {
          code: 201
        }
        params {
          requires :access_token, type: String, desc: 'access token / 访问令牌', documentation: { param_type: 'body' }
          requires :label, type: String, desc: 'Repository address / 仓库地址', documentation: { param_type: 'body', example: 'https://github.com/oss-compass/compass-web-service' }
        }
        post :analyze_criticality_score do

          opts = {
            repo_url: params[:label],
            opencheck_raw: true,
            opencheck_raw_param: {
              commands: ['ohpm-info']
            },
            raw: true,
            enrich: true,
            license: false,
            identities_load: true,
            identities_merge: true,
            activity: false,
            community: false,
            codequality: false,
            group_activity: false,
            domain_persona: false,
            milestone_persona: false,
            role_persona: false,
            criticality_score: true,
            scorecard: false
          }
          result = AnalyzeServer.new(opts).execute_tpc
          Rails.logger.info("analyze criticality score info: #{result}")
          { code: 201, message: 'success' }
        rescue => ex
          { code: 400, message: ex.message }
        end

      end
    end
    end
  end
end
