# frozen_string_literal: true
module Openapi
  module SharedParams
    module Search
      extend Grape::API::Helpers

      params :search do
        requires :access_token, type: String,  desc: 'access token', documentation: { param_type: 'body' }
        requires :label, type: String, desc: '仓库或社区地址', documentation: { param_type: 'body', example: 'https://github.com/oss-compass/compass-web-service' }
        optional :level, type: String, desc: '层级 repo或community', default: 'repo', documentation: { param_type: 'body', example: 'repo' }

        optional :sort, type: String, desc: '排序项', documentation: { param_type: 'body', example: 'created_at' }
        optional :direction, type: String, desc: '排序方向', documentation: { param_type: 'body', example: 'desc' }
        optional :begin_date, type: DateTime, desc: '开始日期', documentation: { param_type: 'body', example: '2010-02-22' }
        optional :end_date, type: DateTime, desc: '结束日期', documentation: { param_type: 'body', example: '2024-03-22' }
        optional :page, type: Integer, default: 1, desc: '页码', documentation: { param_type: 'body' }
        optional :size, type: Integer, default: 20, desc: '每页条数', documentation: { param_type: 'body' }

      end

      params :search_grimoire do
        requires :access_token, type: String,  desc: 'access token', documentation: { param_type: 'body' }
        requires :label, type: String, desc: '仓库或社区地址', documentation: { param_type: 'body', example: 'https://github.com/oss-compass/compass-web-service' }
        optional :level, type: String, desc: '层级 repo或community', default: 'repo', documentation: { param_type: 'body', example: 'repo' }

        optional :sort, type: String, desc: '排序项', documentation: { param_type: 'body', example: 'grimoire_creation_date' }
        optional :direction, type: String, desc: '排序方向', documentation: { param_type: 'body', example: 'desc' }
        optional :begin_date, type: DateTime, desc: '开始日期', documentation: { param_type: 'body', example: '2010-02-22' }
        optional :end_date, type: DateTime, desc: '结束日期', documentation: { param_type: 'body', example: '2024-03-22' }
        optional :page, type: Integer, default: 1, desc: '页码', documentation: { param_type: 'body' }
        optional :size, type: Integer, default: 20, desc: '每页条数', documentation: { param_type: 'body' }
      end

      def extract_search_params!(params)
        label = params[:label]
        level = params[:level] || 'repo'
        filter_opts = params[:filter_opts]&.map { |opt| OpenStruct.new(opt) } || []
        if params[:sort] && params[:direction]
          sort_opts = [OpenStruct.new(type: params[:sort], direction: params[:direction])]
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
