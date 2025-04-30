# frozen_string_literal: true

module Openapi
  module V2
    class Git < Grape::API

      version 'v2', using: :path
      prefix :api
      format :json

      # before { require_login! }
      helpers Openapi::SharedParams::Search
      # github-git_enriched
      # gitee-git_enriched
      resource :git do
        desc 'Query Git data'
        params { use :search }
        post :search do
          label, level, filter_opts, sort_opts, begin_date, end_date, page, size = extract_search_params!(params)

          indexer, repo_urls = select_idx_repos_by_lablel_and_level(label, level, GiteeGitEnrich, GithubGitEnrich)

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
