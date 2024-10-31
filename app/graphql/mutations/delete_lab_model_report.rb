# frozen_string_literal: true

module Mutations
  class DeleteLabModelReport < BaseMutation
    field :status, String, null: false

    argument :id, Integer, required: true, description: "lab model report id"

    def resolve(id: nil)
      current_user = context[:current_user]

      login_required!(current_user)

      report = LabModelReport.find_by(id: id)
      raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless report.present?

      model = LabModel.find_by(id: report.lab_model_id)
      raise GraphQL::ExecutionError.new I18n.t('lab_models.forbidden') unless ::Pundit.policy(current_user, model).update?

      report.destroy!

      { status: true, message: I18n.t('lab_models.delete_success') }
    rescue => ex
      raise GraphQL::ExecutionError.new I18n.t('lab_models.delete_failed', reason: ex.message)
    end
  end
end
