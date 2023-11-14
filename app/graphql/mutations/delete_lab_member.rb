# frozen_string_literal: true

module Mutations
  class DeleteLabMember < BaseMutation
    field :status, String, null: false

    argument :model_id, Integer, required: true, description: 'lab model id'
    argument :member_id, Integer, required: true, description: 'lab member id'

    def resolve(model_id: nil, member_id: nil)
      current_user = context[:current_user]

      login_required!(current_user)

      model = LabModel.find_by(id: model_id)
      raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless model.present?

      member = model.members.find_by(id: member_id)
      raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless member.present?

      unless member.user == current_user  || ::Pundit.policy(current_user, model).cancel?
        raise GraphQL::ExecutionError.new I18n.t('lab_models.forbidden')
      end

      raise GraphQL::ExecutionError.new I18n.t('lab_models.forbidden') if member.is_owner

      member.destroy!

      { status: true, message: I18n.t('lab_models.delete_success') }
    rescue => ex
      raise GraphQL::ExecutionError.new I18n.t('lab_models.delete_failed', reason: ex.message)
    end
  end
end
