# frozen_string_literal: true

module Types
  module Queries
    module Third

      class ThirdTplQuery < BaseQuery

        type Types::Queries::Third::ThirdTplQueryType, null: false

        description ' '
        argument :src_package_name, String, required: true, description: 'src_package_name'
        argument :src_ecosystem, String, required: true, description: 'src_ecosystem'
        argument :target_ecosystem_list, [String], required: true, description: 'target_ecosystem_list'
        argument :top_n, Integer, required: true, description: 'top_n'
        argument :online_judge, Boolean, required: false, description: '是否使用在线评判'
        argument :force_search, Boolean, required: false, description: '是否强制搜索'

        def resolve(src_package_name: nil, src_ecosystem: nil, target_ecosystem_list: nil, top_n: nil, online_judge: false, force_search: false)
          payload = {
            src_package_name: src_package_name,
            src_ecosystem: src_ecosystem,
            target_ecosystem_list: target_ecosystem_list,
            top_n: top_n,
            online_judge: online_judge,
            force_search: force_search
          }

          response = Faraday.post(
            "http://119.13.89.98:8888/query_with_tpl",
            payload.to_json,
            { 'Content-Type' => 'application/json' }
          )


          resp = JSON.parse(response.body)
          puts(resp)
          data = resp['data'] || []

          { items: data }
        end
      end
    end
  end
end
