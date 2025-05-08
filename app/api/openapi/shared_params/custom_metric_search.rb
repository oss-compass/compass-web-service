# frozen_string_literal: true
module Openapi
  module SharedParams
    module CustomMetricSearch
      extend Grape::API::Helpers

      params :custom_metric_search do
        requires :label, type: String, desc: 'repo or community label / 仓库或社区标签', documentation: { param_type: 'body',example: 'https://github.com/oss-compass/compass-web-service' }
        optional :level, type: String, desc: 'level (repo/community), default: repo / 层级', documentation: { param_type: 'body',example: 'repo' }


        optional :filter_opts, type: Array, desc: 'filter options / 筛选条件', documentation: { param_type: 'body' } do
          requires :type, type: String, desc: 'filter option type / 筛选类型'
          requires :values, type: String, desc: 'filter option values / 筛选值'
        end

        optional :sort_opts, type: Array, desc: 'sort options / 排序条件', documentation: { param_type: 'body' ,example: [{ type: 'grimoire_creation_date', direction:  "desc" }]} do
          optional :type, type: String, desc: 'sort type / 排序类型'
          optional :direction, type: String, desc: 'sort direction (asc/desc) / 排序方向'
        end

        optional :begin_date, type: DateTime, desc: 'begin date / 开始日期', documentation: { param_type: 'body' }
        optional :end_date, type: DateTime, desc: 'end date / 结束日期', documentation: { param_type: 'body' }
        optional :page, type: Integer, default: 1, desc: 'page number / 页码', documentation: { param_type: 'body' }
        optional :size, type: Integer, default: 20, desc: 'page size / 每页条数', documentation: { param_type: 'body' }
      end

      def extract_search_params!(params)
        label = params[:label]
        level = params[:level] || 'repo'
        filter_opts = params[:filter_opts]&.map { |opt| OpenStruct.new(opt) } || []
        sort_opts = params[:sort_opts]&.map { |opt| OpenStruct.new(opt) } || []
        begin_date = params[:begin_date]
        end_date = params[:end_date]
        page = params[:page]
        size = params[:size]
        label = ShortenedLabel.normalize_label(label)
        validate_by_label!(label)
        begin_date, end_date = extract_search_date(begin_date, end_date)
        # validate_date!(label, level, begin_date, end_date)

        [label, level, filter_opts, sort_opts, begin_date, end_date, page, size]
      end

      def extract_search_date(begin_date, end_date)
        today = Date.today.end_of_day
        begin_date = begin_date || (today - 3.months)
        end_date = [end_date || today, today].min
        [begin_date, end_date]
      end

    end
  end
end
