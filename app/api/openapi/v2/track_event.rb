# frozen_string_literal: true

module Openapi
  module V2
    class TrackEvent < Grape::API
      version 'v2', using: :path
      prefix :api
      format :json

      helpers Openapi::SharedParams::AuthHelpers
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

      # before { require_login! }
      resource :trackEvent do
        desc '埋点', tags: ['Scene Invocation / 场景调用'], success: {
          code: 201
        }, detail: '埋点', hidden: true
        params do

          requires :events, type: Array[Hash], desc: '埋点事件数组', documentation: { param_type: 'body' }

        end
        post :save do
          created_ids = []

          params[:events].each do |event_params|
            event = TrackingEvent.new(
              event_type: event_params[:event_type],
              timestamp: event_params[:timestamp],
              user_id: event_params[:user_id],
              page_path: event_params[:page_path],
              referrer: event_params[:referrer],
              module_id: event_params[:module_id],
              device_user_agent: event_params[:device_user_agent],
              device_language: event_params[:device_language],
              device_timezone: event_params[:device_timezone],
              data: event_params[:data].to_json,
              ip: request.ip
            )


            # ip
            if event.save
              created_ids << event.id
            else
              error!({ code: 422, message: 'error', errors: event.errors.full_messages }, 422)
            end
          end

          status 201
          { code: 201, message: 'success', ids: created_ids }
        end

        desc 'restapi埋点', tags: ['场景调用'], success: {
          code: 201
        }, detail: 'restapi埋点', hidden: true
        params do
          requires :payload, type: Hash, desc: '参数', documentation: { param_type: 'body', example: {
            user_id: 1,
            api_path: '/some/path',
            domain: 'example.com',
            ip: '127.0.0.1'
          }}
        end
        post :remoteSave do
          user_id = params[:payload][:user_id]
          api_path = params[:payload][:api_path]
          domain = params[:payload][:domain]
          ip = params[:payload][:ip]

          data = TrackingRestapi.new(
            user_id:,
            api_path:,
            domain:,
            ip:
          )
          data.save
          { status: 'saved', user_id:, api_path:, domain:, ip: }
        end

      end
    end
  end
end
