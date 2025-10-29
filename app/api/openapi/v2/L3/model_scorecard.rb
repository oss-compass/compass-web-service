# frozen_string_literal: true

module Openapi
  module V2
    module L3
    class ModelScorecard < Grape::API

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
        desc 'Get Project Scorecard / 获取项目 Scorecard', detail: 'Get Project Scorecard / 获取项目 Scorecard', tags: ['Metrics Model Data / 模型数据'], success: {
          code: 201, model: Openapi::Entities::ScorecardResponse
        }

        params {
          requires :access_token, type: String, desc: 'access token / 访问令牌', documentation: { param_type: 'body' }
          requires :label, type: String, desc: 'Repository address / 仓库地址', documentation: { param_type: 'body', example: 'https://github.com/oss-compass/compass-web-service' }
        }
        post :scorecard do
          opencheckRawIndexer = OpencheckRaw
          indexer = ScorecardMetric
          repo_urls = [params[:label]]

          opencheckRawResp = opencheckRawIndexer.one_by_metric_repo_urls(repo_urls, target: 'label')
          opencheckRawHits = opencheckRawResp&.[]('hits')&.[]('hits') || []
          return {} if opencheckRawHits.empty?

          resp = indexer.one_by_metric_repo_urls(repo_urls)

          hits = resp&.[]('hits')&.[]('hits') || []
          items = hits.map { |data| data['_source'].symbolize_keys }
          items&.first&.reject { |key, _| key.to_s.end_with?('_detail') } || {}
        end

        desc 'Analyze Project Scorecard / 分析项目 Scorecard', detail: 'Analyze Project Scorecard / 分析项目 Scorecard', tags: ['Metrics Model Data / 模型数据'], success: {
          code: 201
        }
        params {
          requires :access_token, type: String, desc: 'access token / 访问令牌', documentation: { param_type: 'body' }
          requires :label, type: String, desc: 'Repository address / 仓库地址', documentation: { param_type: 'body', example: 'https://github.com/oss-compass/compass-web-service' }
          optional :label_token, type: String, desc: 'GitCode access token: Used solely for checking the model Webhooks metrics. If not provided, the check will not be performed / GitCode 访问令牌：仅用于检查 Webhooks 指标。如果不提供，该指标将不会执行检查', documentation: { param_type: 'body' }
        }
        post :analyze_scorecard do
          opts = {
            repo_url: params[:label],
            opencheck_raw: true,
            opencheck_raw_param: {
              access_token: params[:label_token]
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
            criticality_score: false,
            scorecard: true
          }
          result = AnalyzeServer.new(opts).execute_tpc
          Rails.logger.info("analyze scorecard info: #{result}")
          { code: 201, message: 'success' }
        rescue => ex
          { code: 400, message: ex.message }
        end

      end
    end
    end
  end
end
