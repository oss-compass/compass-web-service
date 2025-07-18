# frozen_string_literal: true

module Openapi
  module V2
    module L1
      class Tpc < Grape::API
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
          desc 'Obtain project TPC information / 获取项目tpc信息',
               detail: 'Obtain project TPC information / 获取项目tpc信息',
               tags: ['Opencheck / 项目信息'], success: {
              code: 201, model: Openapi::Entities::OpencheckTpcResponse
            }

          params { use :search }
          post :tpc do
            label, level, filter_opts, sort_opts, begin_date, end_date, page, size = extract_search_params!(params)

            indexer, repo_urls = select_idx_repos_by_lablel_and_level(label, level, OpencheckRaw, OpencheckRaw)

            resp = indexer.terms_by_metric_repo_urls(repo_urls, begin_date, end_date, target: 'label', per: size, page:, filter_opts:, sort_opts:)

            hits = resp&.[]('hits')&.[]('hits') || []
            items = hits.map { |data| data["_source"] }

            result = { scorecard: {} }

            items.each do |item|
              case item['command']
              when 'scorecard-score'
                com_res = item['command_result']
                if com_res && com_res['checks']
                  result[:scorecard][:'total-score'] = com_res['score']

                  com_res['checks'].each do |check|
                    name = check['name'].to_s.downcase.gsub(' ', '-')
                    score = check['score']
                    result[:scorecard][name.to_sym] = score
                  end
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
