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

      resource :metricModel do
        desc '获取项目 Scorecard', detail: '获取项目 Scorecard', tags: ['Metrics Model Data'], success: {
          code: 201, model: Openapi::Entities::ScorecardResponse
        }

        params {
          requires :access_token, type: String, desc: 'access token', documentation: { param_type: 'body' }
          requires :label, type: String, desc: '仓库地址', documentation: { param_type: 'body', example: 'https://github.com/oss-compass/compass-web-service' }
        }
        post :scorecard do

          indexer = ScorecardMetric
          repo_urls = [params[:label]]

          resp = indexer.one_by_metric_repo_urls(repo_urls)


          hits = resp&.[]('hits')&.[]('hits') || []
          items = hits.map { |data| data['_source'].symbolize_keys }
          items.first || {}
        end

      end
    end
    end
  end
end
