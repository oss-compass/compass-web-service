# frozen_string_literal: true
module Openapi
  module SharedParams
    module Search
      extend Grape::API::Helpers

      params :search do
        requires :access_token, type: String, desc: 'access token / 访问令牌', documentation: { param_type: 'body' }
        requires :label, type: String, desc: 'Repository or community address / 仓库或社区地址', documentation: { param_type: 'body', example: 'https://github.com/oss-compass/compass-web-service' }
        optional :level, type: String, desc: 'Level repo or community / 层级 repo或community', default: 'repo',
           values: ['repo', 'community'],
           documentation: { param_type: 'body', example: 'repo' }

        # optional :sort, type: String, desc: 'Sort field / 排序项', documentation: { param_type: 'body', example: 'created_at' }
        optional :direction, type: String, desc: 'Sort direction by time / 按时间排序,排序方向', documentation: { param_type: 'body', example: 'desc' }, values: ['asc', 'desc']
        requires :begin_date, type: DateTime, desc: 'Start date / 开始日期', documentation: { param_type: 'body', example: '2010-02-22' }
        requires :end_date, type: DateTime, desc: 'End date / 结束日期', documentation: { param_type: 'body', example: '2024-03-22' }
        optional :page, type: Integer, default: 1, desc: 'Page number / 页码', documentation: { param_type: 'body' }
        optional :size, type: Integer, default: 10, desc: 'Number of items per page (default 10) / 每页条数 默认10', documentation: { param_type: 'body' }

      end

      params :search_grimoire do
        requires :access_token, type: String, desc: 'access token / 访问令牌', documentation: { param_type: 'body' }
        requires :label, type: String, desc: 'Repository or community address / 仓库或社区地址', documentation: { param_type: 'body', example: 'https://github.com/oss-compass/compass-web-service' }
        optional :level, type: String, desc: 'Level repo or community / 层级 repo或community', default: 'repo', values: ['repo', 'community'], documentation: { param_type: 'body', example: 'repo' }
        optional :direction, type: String, desc: 'Sort direction by time / 按时间排序,排序方向', documentation: { param_type: 'body', example: 'desc' }
        requires :begin_date, type: DateTime, desc: 'Start date / 开始日期', documentation: { param_type: 'body', example: '2010-02-22' }
        requires :end_date, type: DateTime, desc: 'End date / 结束日期', documentation: { param_type: 'body', example: '2024-03-22' }
        optional :page, type: Integer, default: 1, desc: 'Page number / 页码', documentation: { param_type: 'body' }
        optional :size, type: Integer, default: 10, desc: 'Number of items per page (default 10) / 每页条数 默认10', documentation: { param_type: 'body' }
      end

      def extract_search_params!(params)
        label = params[:label]
        level = params[:level] || 'repo'
        filter_opts = params[:filter_opts]&.map { |opt| OpenStruct.new(opt) } || []
        if params[:direction]
          sort_opts = [OpenStruct.new(type: 'created_at', direction: params[:direction])]
        else
          sort_opts = []
        end

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

      def extract_search_grimoire_params!(params)
        label = params[:label]
        level = params[:level] || 'repo'
        filter_opts = params[:filter_opts]&.map { |opt| OpenStruct.new(opt) } || []
        if params[:direction]
          sort_opts = [OpenStruct.new(type: 'grimoire_creation_date', direction: params[:direction])]
        else
          sort_opts = []
        end

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
