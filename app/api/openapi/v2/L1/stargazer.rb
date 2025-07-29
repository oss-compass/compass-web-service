# frozen_string_literal: true
# github-stargazer_enriched 
# gitee-stargazer_enriched
module Openapi
  module V2
    module L1
      class Stargazer < Grape::API

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

      resource :metadata do
        desc 'List project stargazer metadata / 获取项目stargazer元数据', detail: 'List project stargazer metadata / 获取项目stargazer元数据', tags: ['Metadata / 元数据'], success: {
          code: 201, model: Openapi::Entities::StargazerResponse
        }

        params { use :search }
        post :stargazers do
          label, level, filter_opts, sort_opts, begin_date, end_date, page, size = extract_search_params!(params)

          status, message = Openapi::SharedParams::RepoChecker.check_repo!(label, level, current_user)
          return { message: message } unless status

          indexer, repo_urls = select_idx_repos_by_lablel_and_level(label, level, GiteeStargazerEnrich, GithubStargazerEnrich, GitcodeStargazerEnrich)

          resp = indexer.terms_by_repo_urls(repo_urls, begin_date, end_date, per: size, page:, filter_opts:, sort_opts:)

          count = indexer.count_by_repo_urls(repo_urls, begin_date, end_date, filter_opts:)

          hits = resp&.[]('hits')&.[]('hits') || []
          items = hits.map { |data| data["_source"]}


          { count:, total_page: (count.to_f / size).ceil, page:, items: }
        end

      end
    end
    end
  end
end
