# frozen_string_literal: true

module Openapi
  module V1
    class Issue < Grape::API

      version 'v1', using: :path
      prefix :api
      format :json

      before { require_login! }
      helpers Openapi::SharedParams::Export

      resource :issue do
        desc 'Issues',hidden: true
        params { use :export }
        post :export do
          label, level, filter_opts, sort_opts, begin_date, end_date, interval =
                                                                      extract_params!(params)
          indexer, repo_urls =
                   select_idx_repos_by_lablel_and_level(label, level, GiteeIssueEnrich, GithubIssueEnrich, GitcodeIssueEnrich)

          filter_opts << OpenStruct.new(type: 'pull_request', values: ['false']) if indexer == GithubIssueEnrich

          query = indexer
                    .base_terms_by_repo_urls(
                      repo_urls, begin_date, end_date, filter_opts: filter_opts, sort_opts: sort_opts)
                    .to_query

          uuid = get_uuid(indexer.to_s, query.to_s)

          create_export_task(
            {
              uuid: uuid,
              label: label,
              level: level,
              query: query,
              select: indexer.export_headers,
              indexer: indexer.to_s
            }
          )
        end

        desc "Return a export state.",hidden: true
        params do
          requires :uuid, type: String, desc: "task id.", allow_blank: false
        end

        get 'export_state/:uuid' do
          state = Rails.cache.read("export-#{params[:uuid]}")
          return error!('Not Found', 404) unless state.present?
          { code: 200, uuid: params[:uuid] }.merge(refresh_download_path(state))
        end
      end
    end
  end
end
