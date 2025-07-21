# frozen_string_literal: true

module Openapi
  module V2
    module L1

    class Opencheck < Grape::API

      version 'v2', using: :path
      prefix :api
      format :json

      helpers Openapi::SharedParams::Search
      helpers Openapi::SharedParams::AuthHelpers
      helpers Openapi::SharedParams::ErrorHelpers
      helpers Openapi::SharedParams::RestapiHelpers

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
      before { save_tracking_api! }
      

        resource :opencheck do
          desc 'Get project opencheck data / 获取项目opencheck数据', detail: 'Get project opencheck data / 获取项目opencheck数据', tags: ['Metadata / 元数据'], success: {
            code: 201, model: Openapi::Entities::OpencheckRawResponse
          }

          params {
            requires :command, type: String, desc: 'Check command / 检查命令', documentation: { param_type: 'body' }
            use :search
          }
          post :opencheck do
            label, level, filter_opts, sort_opts, begin_date, end_date, page, size = extract_search_params!(params)

            filter_opts << OpenStruct.new({ type: "command.keyword", values: [params[:command]] })

            indexer = OpencheckRaw
            repo_urls = [label]

            resp = indexer.terms_by_metric_repo_urls(repo_urls, begin_date, end_date, target: 'label', per: size, page:, filter_opts:, sort_opts:)

            count = indexer.count_by_metric_repo_urls(repo_urls, begin_date, end_date, target: 'label', filter_opts:)

            hits = resp&.[]('hits')&.[]('hits') || []
            items = hits.map { |data| data['_source'].symbolize_keys }

            { count:, total_page: (count.to_f / size).ceil, page:, items: }
          end

          desc 'Obtain project feature descriptions, official website addresses, and code volume information / 获取项目功能描述、官网地址和代码量信息',
               detail: 'Obtain project feature descriptions, official website addresses, and code volume information / 获取项目功能描述、官网地址和代码量信息',
               tags: ['Metadata / 元数据'], success: {
              code: 201, model: Openapi::Entities::OpencheckPackageInfoResponse
            }

          params { use :search }
          post :package_info do
            label, _, filter_opts, sort_opts, begin_date, end_date, page, size = extract_search_params!(params)

            filter_opts << OpenStruct.new({ type: "command.keyword", values: ['code-count', 'package-info'] })

            indexer, repo_urls = OpencheckRaw, [label]

            resp = indexer.terms_by_metric_repo_urls(repo_urls, begin_date, end_date, target: 'label', per: size, page:,
                                                     filter_opts: filter_opts, sort_opts:)

            hits = resp&.[]('hits')&.[]('hits') || []
            items = hits.map { |data| data["_source"] }

            result = {}

            items.each do |item|
              case item['command']
              when 'code-count'
                if item['command_result']
                  result[:code_count] = item['command_result']['code_count']
                end
              when 'package-info'
                if item['command_result']
                  result[:description] = item['command_result']['description']
                  result[:home_url] = item['command_result']['home_url']
                  result[:dependent_count] = item['command_result']['dependent_count']
                  result[:down_count] = item['command_result']['down_count']
                  result[:day_enter] = item['command_result']['day_enter']
                end
              end
            end

            { count: 1, items: [result] }
          end

          desc 'Retrieve project dependencies and dependents info / 获取项目依赖数、被依赖数信息',
               detail: 'Retrieve project dependencies and dependents info / 获取项目依赖数、被依赖数信息',
               tags: ['Metadata / 元数据'], success: {
              code: 201, model: Openapi::Entities::OpencheckDependentResponse
            }

          params { use :search }
          post :dependent do
            label, _, filter_opts, sort_opts, begin_date, end_date, page, size = extract_search_params!(params)

            filter_opts << OpenStruct.new({ type: "command.keyword", values: ['ohpm-info', 'package-info'] })

            indexer, repo_urls = OpencheckRaw, [label]

            resp = indexer.terms_by_metric_repo_urls(repo_urls, begin_date, end_date, target: 'label', per: size, page:,
                                                     filter_opts: filter_opts, sort_opts:)

            hits = resp&.[]('hits')&.[]('hits') || []
            items = hits.map { |data| data["_source"] }

            result = {}

            items.each do |item|
              case item['command']
              when 'ohpm-info'
                if item['command_result']
                  result[:dependent_ohpm] = item['command_result']['dependent']
                  result[:bedependent_ohpm] = item['command_result']['bedependent']
                end
              when 'package-info'
                if item['command_result']
                  result[:dependent_npm] = item['command_result']['dependent_count']
                end
              end
            end

            { count: 1, items: [result] }
          end

          desc 'Obtain project TPC information / 获取项目tpc信息',
               detail: 'Obtain project TPC information / 获取项目tpc信息',
               tags: ['Metadata / 元数据'], success: {
              code: 201, model: Openapi::Entities::OpencheckTpcResponse
            }

          params { use :search }
          post :tpc do
            label, _, filter_opts, sort_opts, begin_date, end_date, page, size = extract_search_params!(params)

            filter_opts << OpenStruct.new({ type: "command.keyword", values: ['scorecard-score'] })

            indexer, repo_urls = OpencheckRaw, [label]

            resp = indexer.terms_by_metric_repo_urls(repo_urls, begin_date, end_date, target: 'label', per: size, page:,
                                                     filter_opts: filter_opts, sort_opts:)

            hits = resp&.[]('hits')&.[]('hits') || []
            items = hits.map { |data| data["_source"] }

            result = { scorecard: {} }

            items.each do |item|
              case item['command']
              when 'scorecard-score'
                com_res = item['command_result']
                if com_res && com_res['checks']
                  result[:scorecard][:'total-score'] = com_res['score']

                  com_res['checks'].each do |check|
                    name = check['name'].to_s.downcase.gsub(' ', '-')
                    score = check['score']
                    result[:scorecard][name.to_sym] = score
                  end
                end
              end
            end

            { count: 1, items: [result] }
          end

          desc 'Obtain project download statistics / 获取项目下载量信息',
               detail: 'Obtain project download statistics / 获取项目下载量信息',
               tags: ['Metadata / 元数据'], success: {
              code: 201, model: Openapi::Entities::OpencheckDowncountResponse
            }

          params { use :search }
          post :downcount do
            label, _, filter_opts, sort_opts, begin_date, end_date, page, size = extract_search_params!(params)

            filter_opts << OpenStruct.new({ type: "command.keyword", values: ['ohpm-info', 'package-info'] })

            indexer, repo_urls = OpencheckRaw, [label]

            resp = indexer.terms_by_metric_repo_urls(repo_urls, begin_date, end_date, target: 'label', per: size, page:,
                                                     filter_opts: filter_opts, sort_opts:)

            hits = resp&.[]('hits')&.[]('hits') || []
            items = hits.map { |data| data["_source"] }

            result = {}

            items.each do |item|
              case item['command']
              when 'ohpm-info'
                if item['command_result']
                  result[:down_count_ohpm] = item['command_result']['down_count']
                end
              when 'package-info'
                if item['command_result']
                  result[:down_count_npm] = item['command_result']['down_count']
                  result[:day_enter] = item['command_result']['day_enter']
                end
              end
            end

            { count: 1, items: [result] }
          end

          desc 'Obtain project criticality information / 获取项目criticality信息',
               detail: 'Obtain project criticality information / 获取项目criticality信息',
               tags: ['Metadata / 元数据'], success: {
              code: 201, model: Openapi::Entities::OpencheckCriticalityResponse
            }

          params { use :search }
          post :criticality do
            label, _, filter_opts, sort_opts, begin_date, end_date, page, size = extract_search_params!(params)

            filter_opts << OpenStruct.new({ type: "command.keyword", values: ['criticality-score'] })

            indexer, repo_urls = OpencheckRaw, [label]

            resp = indexer.terms_by_metric_repo_urls(repo_urls, begin_date, end_date, target: 'label', per: size, page:,
                                                     filter_opts: filter_opts, sort_opts:)

            hits = resp&.[]('hits')&.[]('hits') || []
            items = hits.map { |data| data["_source"] }

            result = {}

            items.each do |item|
              case item['command']
              when 'criticality-score'
                if item['command_result']
                  result[:criticality_score] = item['command_result']['criticality_score']
                end
              end
            end

            { count: 1, items: [result] }
          end

        end
      end
    end
  end
end
