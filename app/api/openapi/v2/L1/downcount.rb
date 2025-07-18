# frozen_string_literal: true

module Openapi
  module V2
    module L1
      class Downcount < Grape::API
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
        resource :opencheck do
          desc 'Obtain project download statistics / 获取项目下载量信息',
               detail: 'Obtain project download statistics / 获取项目下载量信息',
               tags: ['Opencheck / 项目信息'], success: {
              code: 201, model: Openapi::Entities::OpencheckDowncountResponse
            }

          params { use :search }
          post :downcount do
            label, level, filter_opts, sort_opts, begin_date, end_date, page, size = extract_search_params!(params)

            indexer, repo_urls = select_idx_repos_by_lablel_and_level(label, level, OpencheckRaw, OpencheckRaw)

            resp = indexer.terms_by_metric_repo_urls(repo_urls, begin_date, end_date, target: 'label', per: size, page:, filter_opts:, sort_opts:)

            hits = resp&.[]('hits')&.[]('hits') || []
            items = hits.map { |data| data["_source"] }

            result = {}

            items.each do |item|
              case item['command']
              when 'ohpm-info'
                if item['command_result']
                  result[:down_count_ohpm] = item['command_result']['down_count']
                end
              when 'package-info'
                if item['command_result']
                  result[:down_count_npm] = item['command_result']['down_count']
                  result[:day_enter] = item['command_result']['day_enter']
                end
              end
            end

            { count: 1, items: [result] }
          end

        end
      end
    end
  end
end
