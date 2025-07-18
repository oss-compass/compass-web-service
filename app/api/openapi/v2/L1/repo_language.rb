# frozen_string_literal: true

module Openapi
  module V2
    module L1
      class RepoLanguage < Grape::API
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
        resource :metadata do
          desc 'Obtain project repo language / 获取项目repo语言', detail: 'Obtain project repo language / 获取项目repo语言', tags: ['Metadata / 元数据'], success: {
            code: 201, model: Openapi::Entities::RepoLanguageResponse
          }

          params { use :search }
          post :repo_language do
            label, level, = extract_search_params!(params)

            status, message = Openapi::SharedParams::RepoChecker.check_repo!(label, level)
            return { message: message } unless status

            indexer, repo_urls = select_idx_repos_by_lablel_and_level(label, level, GiteeRepo, GithubRepo, GitcodeRepo)

            resp = indexer.only(repo_urls)

            hits = resp&.[]('hits')&.[]('hits') || []
            items = hits.first ? [{ language: hits.first&.[]("_source")&.[]("data")&.[]("language") }] : []

            { count: 1, items: }
          end

        end
      end
    end
  end
end
