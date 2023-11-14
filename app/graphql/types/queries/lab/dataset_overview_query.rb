# frozen_string_literal: true

module Types
  module Queries
    module Lab
      class DatasetOverviewQuery < BaseQuery

        type [String], null: true
        argument :type, String, required: false, description: ''
        argument :first_ident, String, required: false, description: 'first level ident of collection'
        argument :second_ident, String, required: false, description: 'second level ident of collection'
        description 'Get data of Compass Collections'

        def resolve(first_ident: nil, second_ident: nil)
          current_user = context[:current_user]

          login_required!(current_user)

          if first_ident.present? && second_ident.blank?
            ::BaseCollection.distinct_second_idents(first_ident)
          elsif first_ident.present? && second_ident.present?
            ::BaseCollection.distinct_labels(first_ident, second_ident)
          else
            ::BaseCollection.distinct_first_idents
          end
        end
      end
    end
  end
end
