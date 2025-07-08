# frozen_string_literal: true

module Openapi
  module V2
    class ThirdSoftwareSelection < Grape::API
      version 'v2', using: :path
      prefix :api
      format :json

      helpers Openapi::SharedParams::AuthHelpers
      helpers Openapi::SharedParams::ErrorHelpers

      rescue_from :all do |e|
        case e
        when Grape::Exceptions::ValidationErrors
          handle_validation_error(e)
        when SearchFlip::ResponseError
          handle_open_search_error(e)
        when Openapi::Entities::InvalidVersionNumberError
          handle_release_error(e)
        else
          handle_generic_error(e)
        end
      end

      before { require_token! }
      before do
        token = params[:access_token]
        Openapi::SharedParams::RateLimiter.check_token!(token)
      end

      resource :softwareSelection do

        desc 'Recommend Software by Function Description / 通过功能描述推荐软件', tags: ['Scene Invocation / 场景调用'], success: {
          code: 201, model: Openapi::Entities::RecommendTxtResponse, is_array: true
        }, detail: <<~DETAIL
          Describe your needs and the system will recommend suitable software. / 描述你的需求，系统将推荐合适的软件。
        DETAIL
        params do
          requires :access_token, type: String, desc: 'access token', documentation: { param_type: 'body' }
          requires :query_txt, type: String, desc: 'query txt / 查询文本', documentation: { param_type: 'body', example: 'react' }
          requires :query_keywords, type: Array, desc: 'list of query keywords(can be an empty list) / 查询关键词列表（可为空列表）', documentation: { param_type: 'body', example: [] }
          requires :target_ecosystem_list, type: Array, desc: 'target ecosystem list / 目标来源列表', documentation: { param_type: 'body', example: ['npm'] }
          requires :top_n, type: Integer, desc: 'top n / 返回结果数量', documentation: { param_type: 'body', example: 10 }
          optional :online_judge, type: Boolean, desc: 'online judge(optional,default false) / 是否在线投票 (可选，默认 false)', documentation: { param_type: 'body', example: false }

        end
        post :queryWithTxt do
          query_txt = params[:query_txt]
          query_keywords = params[:query_keywords] || []
          target_ecosystem_list = params[:target_ecosystem_list] || []
          top_n = params[:top_n] || 10
          online_judge = params[:online_judge] || false

          payload = {
            query_txt: query_txt,
            query_keywords: query_keywords,
            target_ecosystem_list: target_ecosystem_list,
            top_n: top_n,
            online_judge: online_judge || false
          }
          url = ENV.fetch('THIRD_URL')
          response =
            Faraday.post(

              "#{url}/query_with_txt",
              payload.to_json,
              { 'Content-Type' => 'application/json' }
            )
          resp = JSON.parse(response.body)

          data = resp['data'] || []
          { items: data }
        end

        desc 'Find Similar Function Software / 查找相似功能软件', tags: ['Scene Invocation / 场景调用'], success: {
          code: 201, model: Openapi::Entities::RecommendTplResponse
        }, detail: <<~DETAIL
          Enter the name of known software to find alternative software with similar functions. / 输入已知软件名称，查找功能相似的替代软件。
        DETAIL
        params do
          requires :access_token, type: String, desc: 'access token', documentation: { param_type: 'body' }
          requires :src_package_name, type: String, desc: 'src package name / 源库名称', documentation: { param_type: 'body', example: 'react' }
          requires :src_ecosystem, type: String, desc: 'src ecosystem / 源库来源', documentation: { param_type: 'body', example: 'npm' }
          requires :target_ecosystem_list, type: Array, desc: 'target ecosystem list / 目标来源列表', documentation: { param_type: 'body', example: ['npm'] }
          requires :top_n, type: Integer, desc: 'top n / 返回结果数量', documentation: { param_type: 'body', example: 10 }
          optional :online_judge, type: Boolean, desc: 'online judge(optional,default false) / 是否在线投票 (可选，默认 false)', documentation: { param_type: 'body', example: false }
          optional :force_search, type: Boolean, desc: 'force_search(optional,default false) / 是否强制搜索 (可选，默认 false)', documentation: { param_type: 'body', example: false }
        end
        post :queryWithTpl do

          src_package_name = params[:src_package_name]
          src_ecosystem = params[:src_ecosystem]
          target_ecosystem_list = params[:target_ecosystem_list]
          top_n = params[:top_n] || 10
          online_judge = params[:online_judge] || false
          force_search = params[:force_search] || false
          payload = {
            src_package_name: src_package_name,
            src_ecosystem: src_ecosystem,
            target_ecosystem_list: target_ecosystem_list,
            top_n: top_n,
            online_judge: online_judge,
            force_search: force_search
          }

          url = ENV.fetch('THIRD_URL')
          response = Faraday.post(
            "#{url}/query_with_tpl",
            payload.to_json,
            { 'Content-Type' => 'application/json' }
          )

          resp = JSON.parse(response.body)
          data = resp['data'] || []

          { items: data }
        end

        desc 'Vote up / 点赞', tags: ['Scene Invocation / 场景调用'], success: {
          code: 201, model: Openapi::Entities::RecommendVoteUpResponse
        }, detail: <<~DETAIL
          Vote up. / 点赞。
        DETAIL
        params do
          requires :access_token, type: String, desc: 'access token', documentation: { param_type: 'body' }
          requires :src_package_name, type: String, desc: 'src package name / 源库名称', documentation: { param_type: 'body', example: 'rc-util' }
          requires :src_ecosystem, type: String, desc: 'src ecosystem / 源库来源', documentation: { param_type: 'body', example: 'npm' }
          requires :target_package_name, type: String, desc: 'src package name / 目标库名称', documentation: { param_type: 'body', example: 'react-semantic-render' }
          requires :target_ecosystem, type: String, desc: 'src ecosystem / 目标库来源', documentation: { param_type: 'body', example: 'npm' }
          requires :who_vote, type: String, desc: 'user name / 用户名', documentation: { param_type: 'body', example: 'anonymous' }

        end
        post :voteUp do
          src_package_name = params[:src_package_name]
          src_ecosystem = params[:src_ecosystem]
          target_package_name = params[:target_package_name]
          target_ecosystem = params[:target_ecosystem]
          who_vote = params[:who_vote] || 'anonymous'

          payload = {
            src_package_name: src_package_name,
            src_ecosystem: src_ecosystem,
            target_package_name: target_package_name,
            target_ecosystem: target_ecosystem,
            who_vote: who_vote,

          }

          url = ENV.fetch('THIRD_URL')
          response = Faraday.post(
            "#{url}/vote_up",
            payload.to_json,
            { 'Content-Type' => 'application/json' }
          )

          resp = JSON.parse(response.body)
          data = resp['data'] || {}
          message = data['message'] || ''
          mapping = {
            'Vote up recorded successfully' => 'vote.vote_up_success'
          }
          key = mapping[message]
          res = key.present? ? I18n.t(key) : message
          { status: true, message: res }
        end

        desc 'Vote down / 点踩', tags: ['Scene Invocation / 场景调用'], success: {
          code: 201, model: Openapi::Entities::RecommendVoteUpResponse
        }, detail: <<~DETAIL
          Vote down. / 点踩。
        DETAIL
        params do
          requires :access_token, type: String, desc: 'access token', documentation: { param_type: 'body' }
          requires :src_package_name, type: String, desc: 'src package name / 源库名称', documentation: { param_type: 'body', example: 'rc-util' }
          requires :src_ecosystem, type: String, desc: 'src ecosystem / 源库来源', documentation: { param_type: 'body', example: 'npm' }
          requires :target_package_name, type: String, desc: 'src package name / 目标库名称', documentation: { param_type: 'body', example: 'react-semantic-render' }
          requires :target_ecosystem, type: String, desc: 'src ecosystem / 目标库来源', documentation: { param_type: 'body', example: 'npm' }
          requires :who_vote, type: String, desc: 'user name / 用户名', documentation: { param_type: 'body', example: 'anonymous' }
        end

        post :voteDown do
          src_package_name = params[:src_package_name]
          src_ecosystem = params[:src_ecosystem]
          target_package_name = params[:target_package_name]
          target_ecosystem = params[:target_ecosystem]
          who_vote = params[:who_vote] || 'anonymous'

          payload = {
            src_package_name: src_package_name,
            src_ecosystem: src_ecosystem,
            target_package_name: target_package_name,
            target_ecosystem: target_ecosystem,
            who_vote: who_vote,

          }

          url = ENV.fetch('THIRD_URL')
          response = Faraday.post(
            "#{url}/vote_down",
            payload.to_json,
            { 'Content-Type' => 'application/json' }
          )

          resp = JSON.parse(response.body)
          data = resp['data'] || {}
          message = data['message'] || ''
          mapping = {
            'Vote down recorded successfully' => 'vote.vote_down_success'
          }
          key = mapping[message]
          res = key.present? ? I18n.t(key) : message
          { status: true, message: res }
        end

      end

    end
  end
end
