# frozen_string_literal: true

module Openapi
  module V2
    module L1
      class Git < Grape::API

      version 'v2', using: :path
      prefix :api
      format :json

      before { require_login! }
      helpers Openapi::SharedParams::Search

      resource :metadata do
        desc '获取项目git元数据', tags: ['Metadata'] , success: {
          code: 201, model: Openapi::Entities::GitResponse
        }
        params { use :search_grimoire }
        post :gits do
          label, level, filter_opts, sort_opts, begin_date, end_date, page, size = extract_search_params!(params)
          label =  label+'.git'

          indexer, repo_urls = select_idx_repos_by_lablel_and_level(label, level, GiteeGitEnrich, GithubGitEnrich)

          resp = indexer.terms_by_repo_urls(repo_urls, begin_date, end_date, filter: 'grimoire_creation_date', sort: 'grimoire_creation_date', per: size, page:, filter_opts:, sort_opts:)

          count = indexer.count_by_repo_urls(repo_urls, begin_date, end_date, filter: 'grimoire_creation_date', filter_opts:)

          hits = resp&.[]('hits')&.[]('hits') || []
          items = hits.map { |data| data["_source"]}


          { count:, total_page: (count.to_f / size).ceil, page:, items: }
        end

      end
    end
    end
  end
end
