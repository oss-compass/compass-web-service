# frozen_string_literal: true

module Openapi
  module V2

      class FeedbackModule < Grape::API
        version 'v2', using: :path
        prefix :api
        format :json

        before do
          require_login!
        end
        helpers Openapi::SharedParams::ErrorHelpers

        rescue_from :all do |e|
          case e
          when Grape::Exceptions::ValidationErrors
            handle_validation_error(e)
          when SearchFlip::ResponseError
            handle_open_search_error(e)
          when Openapi::Entities::InvalidVersionNumberError
            handle_release_error(e)
          else
            handle_generic_error(e)
          end
        end

        resource :feedback do

          desc '保存反馈信息', hidden: true, tags: ['admin'], success: {
            code: 201
          }, detail: '保存反馈信息'

          params do
            requires :module, type: String, documentation: { param_type: 'body' }
            requires :content, type: String, documentation: { param_type: 'body' }
            requires :page, type: String, documentation: { param_type: 'body' }

          end

          post :save_data do
            user = @current_user
            module_name = params[:module]
            content = params[:content]
            page = params[:page]

            Feedback.create!(user_id: user.id, module: module_name, content: content, page: page)


            {
              message: 'ok'
            }
          end




        end
      end
    end

end

