# frozen_string_literal: true

module Openapi
  module V1
    class Issue < Grape::API

      version 'v1', using: :path
      prefix :api
      format :json

      before do
        error!(I18n.t('users.require_login'), 400) unless current_user.present?
      end

      resource :issue do
        desc 'Issues'

        params do
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

        post :export do
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

          indexer, repo_urls =
                   select_idx_repos_by_lablel_and_level(label, level, GiteeIssueEnrich, GithubIssueEnrich)

          filter_opts << OpenStruct.new(type: 'pull_request', values: ['false']) if indexer == GithubIssueEnrich

          query = indexer
                    .base_terms_by_repo_urls(
                      repo_urls, begin_date, end_date, filter_opts: filter_opts, sort_opts: sort_opts)
                    .to_query

          uuid = get_uuid(query.to_s)

          state = Rails.cache.read("export-#{uuid}")
          if state && state[:status] == ::Subject::COMPLETE || state[:status] == ::Subject::PROGRESS
            return { code: 200, uuid: uuid }.merge(state)
          end

          state = { status: ::Subject::PENDING }

          Rails.cache.write("export-#{uuid}", state, expires_in: Common::EXPORT_CACHE_TTL)

          RabbitMQ.publish(
            Common::EXPORT_TASK_QUEUE,
            {
              uuid: uuid,
              label: label,
              level: level,
              query: query,
              select: Types::Meta::IssueDetailType.fields.keys.map(&:underscore),
              indexer: indexer.to_s
            }
          )
          { code: 200, uuid: uuid }.merge(state)
        end

        desc "Return a export state."
        params do
          requires :uuid, type: String, desc: "task id.", allow_blank: false
        end

        get 'export_state/:uuid' do
          state = Rails.cache.read("export-#{params[:uuid]}")
          return error!('Not Found', 404) unless state.present?
          { code: 200, uuid: params[:uuid] }.merge(state)
        end
      end
    end
  end
end
