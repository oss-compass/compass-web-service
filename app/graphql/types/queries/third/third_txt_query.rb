# frozen_string_literal: true

module Types
  module Queries
    module Third
      class ThirdTxtQuery < BaseQuery

        type Types::Queries::Third::ThirdTxtQueryType, null: false

        description ' '
        argument :query_txt, String, required: true, description: 'query txt'
        argument :query_keywords, [String], required: false, description: 'query keywords'
        argument :target_ecosystem_list, [String], required: true, description: 'target ecosystem list'
        argument :top_n, Integer, required: true, description: 'top_n'
        argument :online_judge, Boolean, required: false, description: 'online judge'

        def resolve(query_txt: nil, query_keywords: nil, target_ecosystem_list: nil, top_n: nil, online_judge: nil)
          # 发送请求调用第三方服务 返回信息


          payload = {
            query_txt: query_txt,
            query_keywords: query_keywords,
            target_ecosystem_list: target_ecosystem_list,
            top_n: top_n,
            online_judge: online_judge || false
          }
          response =
            Faraday.post(
              # "#{_SERVER}/api/workflows",
              "http://119.13.89.98:8888/query_with_txt",
              payload.to_json,
              { 'Content-Type' => 'application/json' }
            )
          resp = JSON.parse(response.body)


          data = resp['data'] || []
          { items: data }
        end
      end
    end
  end
end
