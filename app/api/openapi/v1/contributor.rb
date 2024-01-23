# frozen_string_literal: true

module Openapi
  module V1
    class Contributor < Grape::API

      version 'v1', using: :path
      prefix :api
      format :json

      before { require_login! }
      helpers Openapi::SharedParams::Export

      resource :contributor do
        desc 'Contributors'
        params { use :export }
        post :export do
          label, level, filter_opts, sort_opts, begin_date, end_date, interval =
                                                                      extract_params!(params)

          indexer, repo_urls =
                   select_idx_repos_by_lablel_and_level(label, level, GiteeContributorEnrich, GithubContributorEnrich)

          uuid = get_uuid(indexer.to_s, label, level, filter_opts.to_json, sort_opts.to_json, begin_date.to_s, end_date.to_s)


          contributors_list =
            indexer
              .fetch_contributors_list(repo_urls, begin_date, end_date, label: label, level: level)
              .then { indexer.filter_contributors(_1, filter_opts) }
              .then { indexer.sort_contributors(_1, sort_opts) }

          create_export_task(
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
