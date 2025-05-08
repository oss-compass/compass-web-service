# frozen_string_literal: true

module Openapi
  module V2
    class CustomMetric < Grape::API
      version 'v2', using: :path
      prefix :api
      format :json

      # before { require_login! }
      helpers Openapi::SharedParams::CustomMetricSearch

      resource :custom_metric do
        desc 'Query domain_persona data', { tags: ['L2 Portrait/Metric data'] }
        params { use :custom_metric_search }
        puts(params.inspect)
        post :search do
          label, level, filter_opts, sort_opts, begin_date, end_date, page, size = extract_search_params!(params)

          indexer = CustomV2Metric
          repo_urls = [label]

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
