# frozen_string_literal: true
module Openapi
  module SharedParams
    module CustomMetricSearch
      extend Grape::API::Helpers

      params :community_portrait_search do
        requires :access_token, type: String, desc: 'Access token / 访问令牌', documentation: { param_type: 'body' }
        requires :label, type: String, desc: 'Repository or community URL / 仓库或社区地址', documentation: { param_type: 'body', example: 'https://github.com/oss-compass/compass-web-service' }
        requires :begin_date, type: DateTime, desc: 'Start date / 开始日期', documentation: { param_type: 'body', example: '2010-02-22' }
        requires :end_date, type: DateTime, desc: 'End date / 结束日期', documentation: { param_type: 'body', example: '2024-03-22' }
        optional :page, type: Integer, default: 1, desc: 'Page number / 页码', documentation: { param_type: 'body' }
        optional :size, type: Integer, default: 10, desc: 'Items per page (default: 10) / 每页条数 (默认10)', documentation: { param_type: 'body' }
      end

      params :contributor_portrait_search do
        # requires :access_token, type: String, desc: 'Access token / 访问令牌', documentation: { param_type: 'body' }
        requires :contributor, type: String, desc: 'Contributor name / 开发者名称', documentation: { param_type: 'body', example: 'Github username / Github 用户名称' }
        requires :begin_date, type: DateTime, desc: 'Start date / 开始日期', documentation: { param_type: 'body', example: '2010-02-22' }
        requires :end_date, type: DateTime, desc: 'End date / 结束日期', documentation: { param_type: 'body', example: '2024-03-22' }
      end

      params :software_artifact_portrait_search do
        requires :access_token, type: String, desc: 'Access token / 访问令牌', documentation: { param_type: 'body' }
        requires :label, type: String, desc: 'Repository or community URL / 仓库或社区地址', documentation: { param_type: 'body', example: 'https://github.com/oss-compass/compass-web-service' }
        optional :version_number, type: String, desc: 'Version number / 版本号', documentation: { param_type: 'body', example: 'v4.0.3' }
        requires :begin_date, type: DateTime, desc: 'Start date / 开始日期', documentation: { param_type: 'body', example: '2010-02-22' }
        requires :end_date, type: DateTime, desc: 'End date / 结束日期', documentation: { param_type: 'body', example: '2024-03-22' }
        optional :page, type: Integer, default: 1, desc: 'Page number / 页码', documentation: { param_type: 'body' }
        optional :size, type: Integer, default: 10, desc: 'Items per page (default: 10) / 每页条数 (默认10)', documentation: { param_type: 'body' }
      end


      params :metric_search do
        requires :label, type: String, desc: 'Repository or community address / 仓库或社区地址', documentation: { param_type: 'body', example: 'https://github.com/oss-compass/compass-web-service' }
        requires :period, type: String, desc: 'Time period / 时间周期', documentation: { param_type: 'body', example: 'month,year,quarter' }
        optional :level, type: String, desc: 'Level repo or community / 层级 repo或community', default: 'repo', values: ['repo', 'community'], documentation: { param_type: 'body', example: 'repo' }
        optional :begin_date, type: DateTime, desc: 'Start date / 开始日期', documentation: { param_type: 'body', example: '2010-02-22' }
        optional :end_date, type: DateTime, desc: 'End date / 结束日期', documentation: { param_type: 'body', example: '2024-03-22' }
        optional :page, type: Integer, default: 1, desc: 'Page number / 页码', documentation: { param_type: 'body' }
        optional :size, type: Integer, default: 10, desc: 'Number of items per page (default 10) / 每页条数 默认10', documentation: { param_type: 'body' }
      end

      params :search_model do
        requires :label, type: String, desc: 'Repository or community address / 仓库或社区地址', documentation: { param_type: 'body', example: 'https://github.com/oss-compass/compass-web-service' }
        requires :period, type: String, desc: 'Time period / 时间周期', documentation: { param_type: 'body', example: 'month,year,quarter' }
        optional :level, type: String, desc: 'Level repo or community / 层级 repo或community', default: 'repo', values: ['repo', 'community'], documentation: { param_type: 'body', example: 'repo' }

        optional :direction, type: String, desc: 'Sort direction by time / 按时间排序,排序方向', documentation: { param_type: 'body', example: 'desc' }
        optional :begin_date, type: DateTime, desc: 'Start date / 开始日期', documentation: { param_type: 'body', example: '2010-02-22' }
        optional :end_date, type: DateTime, desc: 'End date / 结束日期', documentation: { param_type: 'body', example: '2024-03-22' }
        optional :page, type: Integer, default: 1, desc: 'Page number / 页码', documentation: { param_type: 'body' }
        optional :size, type: Integer, default: 10, desc: 'Number of items per page (default 10) / 每页条数 默认10', documentation: { param_type: 'body' }
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

      def extract_search_model_params!(params)
        period = params[:period] || 'month'
        label = ShortenedLabel.normalize_label(params[:label])
        level = params[:level] || 'repo'
        page = params[:page]
        size = params[:size]

        begin_date, end_date = extract_search_date(params[:begin_date], params[:end_date])

        validate_by_label!(label)

        filter_opts = params[:filter_opts]&.map { |opt| OpenStruct.new(opt) } || []

        if period.present?
          filter_opts << OpenStruct.new(type: 'period', values: [period])
        end

        sort_opts = if params[:direction]
                      [OpenStruct.new(type: 'grimoire_creation_date', direction: params[:direction])]
                    else
                      []
                    end

        [label, level, filter_opts, sort_opts, begin_date, end_date, page, size]
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



      def fetch_metric_data_v2(indexer, field_or_fields)
        label, level, begin_date, end_date, page, size = extract_search_params!(params)
        repo_urls = [label]
        filter_opts = []

        base_fields = %w[uuid level type label model_name period grimoire_creation_date]

        target_fields = base_fields + Array(field_or_fields).map(&:to_s)

        resp = indexer.terms_by_metric_repo_urls(
          repo_urls, begin_date, end_date,
          per: size, page: page, filter_opts: filter_opts
        )
        count = indexer.count_by_metric_repo_urls(repo_urls, begin_date, end_date, filter_opts: filter_opts)

        hits = resp&.[]('hits')&.[]('hits') || []
        items = hits.map do |data|
          source = data['_source'] || {}
          source.slice(*target_fields).symbolize_keys
        end

        {
          count: count,
          total_page: (count.to_f / size).ceil,
          page: page,
          items: items
        }
      end
      # def fetch_metric_data_v2(indexer,field)
      #
      #   label, level, begin_date, end_date, page, size = extract_search_params!(params)
      #
      #   repo_urls = [label]
      #   filter_opts = []
      #   resp = indexer.terms_by_metric_repo_urls(repo_urls, begin_date, end_date, per: size, page:, filter_opts:)
      #   count = indexer.count_by_metric_repo_urls(repo_urls, begin_date, end_date, filter_opts:)
      #
      #   hits = resp&.[]('hits')&.[]('hits') || []
      #   # items = hits.map { |data| data['_source'].symbolize_keys }
      #   items = hits.map { |data| data.dig('_source', field.to_s) }.compact
      #
      #   { count:, total_page: (count.to_f / size).ceil, page:, items: }
      # end
    end
  end
end
