# frozen_string_literal: true
module Openapi
  module SharedParams
    module Export
      extend Grape::API::Helpers

      params :export do
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
      end

      def extract_params!(params)
        label = params[:label]
        level = params[:level] || 'repo'
        filter_opts = params[:filter_opts]&.map{ |opt| OpenStruct.new(opt) } || []
        sort_opts = params[:sort_opts]&.map{ |opt| OpenStruct.new(opt) } || []
        begin_date = params[:begin_date]
        end_date = params[:end_date]
        label = ShortenedLabel.normalize_label(label)
        validate_by_label!(label)
        begin_date, end_date, interval = extract_date(begin_date, end_date)
        validate_date!(label, level, begin_date, end_date)

        [label, level, filter_opts, sort_opts, begin_date, end_date, interval]
      end

      def refresh_download_path(state)
        blob = state[:blob_id] ? ActiveStorage::Attachment.find_by(blob_id: state[:blob_id], name: 'exports') : nil
        state[:download_path] = Rails.application.routes.url_helpers.rails_blob_path(blob, only_path: true) if blob
        state
      end

      def create_export_task(opts)
        uuid = opts[:uuid]
        state = Rails.cache.read("export-#{uuid}")
        if state && (state[:status] == ::Subject::COMPLETE || state[:status] == ::Subject::PROGRESS)
          return { code: 200, uuid: uuid }.merge(refresh_download_path(state))
        end
        state = { status: ::Subject::PENDING }
        Rails.cache.write("export-#{uuid}", state, expires_in: Common::EXPORT_CACHE_TTL)
        RabbitMQ.publish(Common::EXPORT_TASK_QUEUE, opts)
        { code: 200, uuid: uuid }.merge(refresh_download_path(state))
      end
    end
  end
end
