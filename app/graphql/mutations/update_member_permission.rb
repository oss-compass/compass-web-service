# frozen_string_literal: true

module Mutations
  class UpdateMemberPermission < BaseMutation
    field :data, Types::Lab::LabMemberType, null: true

    argument :model_id, Integer, required: true, description: 'lab model id'
    argument :member_id, Integer, required: true, description: 'lab member id'
    argument :can_update, Boolean, required: false, description: 'permission to change model properties'
    argument :can_execute, Boolean, required: false, description: 'permission to execute model analysis'

    def resolve(model_id: nil, member_id: nil, can_update: nil, can_execute: nil)
      current_user = context[:current_user]

      login_required!(current_user)

      model = LabModel.find_by(id: model_id)
      raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless model.present?
      raise GraphQL::ExecutionError.new I18n.t('lab_models.forbidden') unless ::Pundit.policy(current_user, model).update?

      member = model.members.find_by(id: member_id)
      raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless member.present?
      member.update_permission!(can_update: can_update, can_execute: can_execute)
      { data: member }
    rescue => ex
      raise GraphQL::ExecutionError.new I18n.t('lab_models.update_failed', reason: ex.message)
    end
  end
end
