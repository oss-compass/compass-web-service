# frozen_string_literal: true

module Openapi
  module V1
    class Contributor < Grape::API
      version 'v1', using: :path
      prefix :api

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
          contributors_list =
            indexer
              .fetch_contributors_list(repo_urls, begin_date, end_date)
              .then { indexer.filter_contributors(_1, filter_opts) }
              .then { indexer.sort_contributors(_1, sort_opts) }
          csv_data =
            CSV.generate(headers: true) do |csv|
            csv << contributors_list.first.keys
            contributors_list.each do |row|
              csv << row
            end
          end
          content_type 'text/csv'
          header['Content-Disposition'] = "attachment; filename=contributors-list-#{Date.today.to_s}.csv"
          env['api.format'] = :csv
          body csv_data
        end
      end
    end
  end
end
