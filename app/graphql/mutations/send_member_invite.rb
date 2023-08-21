# frozen_string_literal: true

module Mutations
  class SendMemberInvite < BaseMutation
    field :status, String, null: false

    argument :model_id, Integer, required: true, description: 'lab model id'
    argument :emails, [String], required: true, description: 'target member emails'
    argument :can_update, Boolean, required: false, description: 'permission to change model properties, `default: false`'
    argument :can_execute, Boolean, required: false, description: 'permission to execute model analysis, `default: false`'

    def resolve(model_id: nil, emails: [], can_update: false, can_execute: false)
      current_user = context[:current_user]
      raise GraphQL::ExecutionError.new I18n.t('users.require_login') if current_user.blank?

      model = LabModel.find_by(id: model_id)
      raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless model.present?
      raise GraphQL::ExecutionError.new I18n.t('lab_models.forbidden') unless ::Pundit.policy(current_user, model).invite?
      raise GraphQL::ExecutionError.new I18n.t('lab_models.emails_required') unless emails.present?
      raise GraphQL::ExecutionError.new I18n.t('lab_models.reach_limit') if emails.length > 5

      permission = LabModelMember::Read
      permission |= LabModelMember::Update if can_update
      permission |= LabModelMember::Execute if can_execute

      emails.each do |email|
        current_user.send_email_invitation(email, model, permission)
        full_messages = current_user.errors.full_messages
        raise GraphQL::ExecutionError.new full_messages.first if full_messages.present?
      end

      { status: true, message: 'ok' }
    rescue => ex
      { status: false, message: ex.message }
    end
  end
end
