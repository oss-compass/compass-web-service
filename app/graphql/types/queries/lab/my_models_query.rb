# frozen_string_literal: true

module Types
  module Queries
    module Lab
      class MyModelsQuery < BaseQuery
        include Pagy::Backend

        type Types::Lab::MyModelsType, null: true
        description 'Get detail data of my lab models'
        argument :page, Integer, required: false, description: 'page number'
        argument :per, Integer, required: false, description: 'per page number'

        def resolve(page: 1, per: 3)
          current_user = context[:current_user]

          login_required!(current_user)

          pagyer, records = pagy(current_user.lab_models_has_participated_in, { page: page, items: per })
          { count: pagyer.count, total_page: pagyer.pages, page: pagyer.page, items: records }
        end
      end
    end
  end
end
