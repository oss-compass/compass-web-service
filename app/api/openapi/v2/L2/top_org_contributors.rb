# frozen_string_literal: true

module Openapi
  module V2
    module L2
      class TopOrgContributors < Grape::API
        version 'v2', using: :path
        prefix :api
        format :json

        helpers Openapi::SharedParams::CustomMetricSearch
        helpers Openapi::SharedParams::AuthHelpers
        helpers Openapi::SharedParams::ErrorHelpers
        helpers Openapi::SharedParams::Contributes

        rescue_from :all do |e|
          case e
          when Grape::Exceptions::ValidationErrors
            handle_validation_error(e)
          when SearchFlip::ResponseError
            handle_open_search_error(e)
          else
            handle_generic_error(e)
          end
        end

        before { require_token! }
        before do
          token = params[:access_token]
          Openapi::SharedParams::RateLimiter.check_token!(token)
        end

        resource :community_portrait do

          # 代码
          desc 'TOP10贡献者所属组织分布',
               detail: 'TOP10贡献者所属组织分布',
               tags: ['Metrics Data / 指标数据', 'Community Persona / 社区画像']
          params { use :community_portrait_search }
          post :top_org_contributors do
            # 参数解析
            label, level, begin_date, end_date = extract_search_params!(params)
            label = ShortenedLabel.normalize_label(label)
            filter_opts = []
            begin_date, end_date, = extract_date(begin_date, end_date)

            # 选择索引类
            indexer, repo_urls =
              select_idx_repos_by_lablel_and_level(label, level, GiteeContributorEnrich, GithubContributorEnrich)

            # 获取贡献者列表 & 过滤
            contributors_list =
              indexer
                .fetch_contributors_list(repo_urls, begin_date, end_date, label: label, level: level)
                .then { indexer.filter_contributors(_1, filter_opts) }

            total_count = contributors_list.length
            grouped_data = contributors_list.group_by { _1['ecological_type'] }
            org_contributors_distribution = grouped_data.map do |group, _|
              build_org_dis_data(group, grouped_data[group], total_count, scope: 'contributor')
            end
            items = { orgContributorsDistribution: org_contributors_distribution }
            { count: org_contributors_distribution.length, total_page: 1, page: 1, items: }
          end
        end
      end
    end
  end
end
