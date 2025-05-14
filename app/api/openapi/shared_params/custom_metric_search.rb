# frozen_string_literal: true
module Openapi
  module SharedParams
    module CustomMetricSearch
      extend Grape::API::Helpers

      params :custom_metric_search do
        requires :label, type: String, desc: 'repo or community label / 仓库或社区标签', documentation: { param_type: 'body',example: 'https://github.com/oss-compass/compass-web-service' }
        optional :begin_date, type: DateTime, desc: 'begin date / 开始日期', documentation: { param_type: 'body' }
        optional :end_date, type: DateTime, desc: 'end date / 结束日期', documentation: { param_type: 'body' }
        optional :page, type: Integer, default: 1, desc: 'page number / 页码', documentation: { param_type: 'body' }
        optional :size, type: Integer, default: 20, desc: 'page size / 每页条数', documentation: { param_type: 'body' }
      end

      def extract_search_params!(params)
        label = params[:label]
        level = params[:level] || 'repo'
        begin_date = params[:begin_date]
        end_date = params[:end_date]
        page = params[:page]
        size = params[:size]
        label = ShortenedLabel.normalize_label(label)
        validate_by_label!(label)
        begin_date, end_date = extract_search_date(begin_date, end_date)
        # validate_date!(label, level, begin_date, end_date)

        [label, level, begin_date, end_date, page, size]
      end

      def extract_search_date(begin_date, end_date)
        today = Date.today.end_of_day
        begin_date = begin_date || (today - 3.months)
        end_date = [end_date || today, today].min
        [begin_date, end_date]
      end

      def fetch_metric_data(metric_name: nil, version_number: nil)
        filter_opts = [OpenStruct.new({ type: "metric_name", values: [metric_name] })]
        filter_opts << OpenStruct.new({ type: "version_number", values: [version_number] }) if version_number
        label, level, begin_date, end_date, page, size = extract_search_params!(params)

        indexer = CustomV2Metric
        repo_urls = [label]

        resp = indexer.terms_by_metric_repo_urls(repo_urls, begin_date, end_date, per: size, page:, filter_opts:)
        count = indexer.count_by_metric_repo_urls(repo_urls, begin_date, end_date, filter_opts:)

        hits = resp&.[]('hits')&.[]('hits') || []
        items = hits.map { |data| data['_source'].symbolize_keys }

        { count:, total_page: (count.to_f / size).ceil, page:, items: }
      end
    end
  end
end
