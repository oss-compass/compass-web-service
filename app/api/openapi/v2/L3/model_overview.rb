# frozen_string_literal: true

module Openapi
  module V2
    module L3
      class ModelOverview < Grape::API

        version 'v2', using: :path
        prefix :api
        format :json

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

        resource :metricModel do
          desc 'Get Metric Models Graph / 获取模型图',hidden: true, detail: 'Get Metric Models Graph / 获取模型图', tags: ['Metrics Model Data / 模型数据'], success: {
            code: 201, model: Openapi::Entities::ModelOverviewResponse
          }

          params do
            requires :label, type: String, documentation: { param_type: 'body' }
            optional :level, type: String, documentation: { param_type: 'body' }
            optional :repo_type, type: String, desc: 'repo type (default: null for repo, software-artifact for community)', documentation: { param_type: 'body' }
          end

          post :graph do

            params[:level] = 'repo' if params[:level].blank?
            unless %w[repo community].include?(params[:level])
              error!({ code: 400, message: "level 参数必须为 'repo' 或 'community'" }, 400)
            end

            if params[:level] == 'community'
              params[:repo_type] = 'software-artifact'
            end

            if params[:level] == 'repo'
              params[:repo_type] = nil
            end
            result = MetricModelsServer.new(
              label: params[:label],
              level: params[:level],
              repo_type: params[:repo_type]
            ).overview

            { code: 201, message: 'Success', data: result }
          end

        end
      end
    end
  end
end
