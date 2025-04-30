# frozen_string_literal: true
module Openapi
  module SharedParams
    module Search
      extend Grape::API::Helpers

      params :search do
        requires :label, type: String, desc: 'repo or community label'
        optional :level, type: String, desc: 'level (repo/community), default: repo'
        optional :filter_opts, type: Array[JSON], desc: 'filter options' do
          requires :type, type: String, desc: 'filter option type'
          requires :values, type: Array, desc: 'filter option value'
        end
        optional :sort_opts, type: Array[JSON], desc: 'sort options' do
          requires :type, type: String, desc: 'sort type value'
          requires :direction, type: String, desc: 'sort direction, optional: desc, asc, default: desc'
        end
        optional :begin_date, type: DateTime, desc: 'begin date'
        optional :end_date, type: DateTime, desc: 'end date'

        optional :page, type: Integer, default: 1
        optional :size, type: Integer, default: 20
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
