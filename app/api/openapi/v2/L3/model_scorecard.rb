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
          items.first.select { |key, _| !key.to_s.end_with?('_detail') } || {}
        end

        desc '触发 Scorecard', detail: '触发 Scorecard', tags: ['Metrics Model Data'], success: {
          code: 201
        }
        params {
          requires :access_token, type: String, desc: 'access token', documentation: { param_type: 'body' }
          requires :label, type: String, desc: '仓库地址', documentation: { param_type: 'body', example: 'https://github.com/oss-compass/compass-web-service' }
          optional :label_token, type: String, desc: 'GitCode access token: Used solely for checking the model Webhooks metrics. If not provided, the check will not be performed', documentation: { param_type: 'body' }
        }
        post :trigger_scorecard do
          unless params[:label].include?("gitcode.com")
            return { code: 400, message: 'only supports the gitCode repo' }
          end

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
          Rails.logger.info("trigger scorecard info: #{result}")
          { code: 201, message: 'success' }
        rescue => ex
          { code: 400, message: ex.message }
        end

      end
    end
    end
  end
end
