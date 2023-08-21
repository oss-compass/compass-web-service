# frozen_string_literal: true

module Types
  module Queries
    module Lab
      class MyMemberPermissionQuery < BaseQuery
        type Types::Lab::PermissionType, null: true
        description 'Get my member permissions of a lab model'

        argument :model_id, Integer, required: false, description: 'lab mode id'

        def resolve(model_id: )
          current_user = context[:current_user]
          raise GraphQL::ExecutionError.new I18n.t('users.require_login') if current_user.blank?

          model = LabModel.find_by(id: model_id)

          raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless model.present?

          current_user.my_member_permission_of(model)
        end
      end
    end
  end
end
