# frozen_string_literal: true

module Openapi
  module V2
    module L3
    class ModelCiiBestBadge < Grape::API

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



      # before { require_token! }
      # before do
      #   token = params[:access_token]
      #   Openapi::SharedParams::RateLimiter.check_token!(token)
      # end

      resource :metricModel do
        desc 'Get Project CII Best Badge / 获取项目 CII Best Badge', detail: 'Get Project CII Best Badge / 获取项目 CII Best Badge', tags: ['Metrics Model Data / 模型数据'], success: {
          code: 201, model: Openapi::Entities::CiiBestBadgeResponse
        }

        params {
          requires :access_token, type: String, desc: 'access token / 访问令牌', documentation: { param_type: 'body' }
          requires :label, type: String, desc: 'Repository address / 仓库地址', documentation: { param_type: 'body', example: 'https://github.com/ossf/scorecard' }
        }
        post :cii_best_badge do
          resp = Faraday.get(
              "https://www.bestpractices.dev/projects.json?url=#{params[:label]}"
            )
          if resp.success?
            parsed_body = JSON.parse(resp.body)
            body = {}
            if parsed_body.length > 0
              body = parsed_body[0]
            end
            { code: 201, body: body }
          else
            { code: resp.status, body: "API request failed: #{resp.body}" }
          end
        rescue => ex
          { code: 500, body: "Server internal error" }
        end

      end
    end
    end
  end
end
