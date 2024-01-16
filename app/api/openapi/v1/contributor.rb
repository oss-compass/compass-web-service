# frozen_string_literal: true

module Openapi
  module V1
    class Contributor < Grape::API

      version 'v1', using: :path
      prefix :api
      format :json

      before do
        error!(I18n.t('users.require_login'), 400) unless current_user.present?
      end

      resource :contributor do
        desc 'Contributors'
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
                   select_idx_repos_by_lablel_and_level(label, level, GiteeContributorEnrich, GithubContributorEnrich)

          uuid = get_uuid(indexer.to_s, label, level, filter_opts.to_json, sort_opts.to_json, begin_date.to_s, end_date.to_s)

          state = Rails.cache.read("export-#{uuid}")
          if state && (state[:status] == ::Subject::COMPLETE || state[:status] == ::Subject::PROGRESS)
            return { code: 200, uuid: uuid }.merge(state)
          end

          state = { status: ::Subject::PENDING }

          Rails.cache.write("export-#{uuid}", state, expires_in: Common::EXPORT_CACHE_TTL)

          contributors_list =
            indexer
              .fetch_contributors_list(repo_urls, begin_date, end_date)
              .then { indexer.filter_contributors(_1, filter_opts) }
              .then { indexer.sort_contributors(_1, sort_opts) }

          RabbitMQ.publish(
            Common::EXPORT_TASK_QUEUE,
            {
              uuid: uuid,
              label: label,
              level: level,
              query: nil,
              raw_data: contributors_list,
              select: indexer.export_headers,
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
