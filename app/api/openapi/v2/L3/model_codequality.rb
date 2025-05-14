# frozen_string_literal: true

module Openapi
  module V2
    module L3
    class ModelCodequality < Grape::API

      version 'v2', using: :path
      prefix :api
      format :json

      before { require_login! }
      helpers Openapi::SharedParams::Search

      resource :metricModel do
        desc '获取项目协作开发指数', { tags: ['L3 Evaluate model data'] }
        params { use :search }
        post :collaborationDevelopmentIndex do
          label, level, filter_opts, sort_opts, begin_date, end_date, page, size = extract_search_params!(params)

          indexer = CodequalityMetric
          # indexer = CodequalitySummary
          repo_urls = [label]
          # indexer, repo_urls = select_idx_repos_by_lablel_and_level(label, level, GiteePullEnrich, CodequalityMetric)

          resp = indexer.terms_by_metric_repo_urls(repo_urls, begin_date, end_date, per: size, page:, filter_opts:, sort_opts:)

          count = indexer.count_by_metric_repo_urls(repo_urls, begin_date, end_date, filter_opts:)

          hits = resp&.[]('hits')&.[]('hits') || []
          items = hits.map { |data| data['_source'].symbolize_keys }

          { count:, total_page: (count.to_f / size).ceil, page:, items: }
        end

      end
    end
    end
  end
end
