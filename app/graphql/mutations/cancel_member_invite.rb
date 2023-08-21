# frozen_string_literal: true

module Mutations
  class CancelMemberInvite < BaseMutation
    field :status, String, null: false

    argument :model_id, Integer, required: true, description: 'lab model id'
    argument :invitation_id, Integer, required: true, description: 'invitation id'

    def resolve(model_id: nil, invitation_id: nil)
      current_user = context[:current_user]
      raise GraphQL::ExecutionError.new I18n.t('users.require_login') if current_user.blank?

      model = LabModel.find_by(id: model_id)
      raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless model.present?
      raise GraphQL::ExecutionError.new I18n.t('lab_models.forbidden') unless ::Pundit.policy(current_user, model).cancel?

      invitation = model.invitations.find_by(id: invitation_id)
      raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless invitation.present?

      invitation.update!(status: :cancel)

      { status: true, message: 'ok' }
    rescue => ex
      { status: false, message: ex.message }
    end
  end
end
