# frozen_string_literal: true

module Types
  module Queries
    module Lab
      class CustomAnalysisStatusQuery < BaseQuery

        type String, null: false
        description 'Get custom lab model analysis status (pending/progress/success/error/canceled/unsumbit)'
        argument :model_id, Integer, required: true, description: 'lab model id'
        argument :version_id, Integer, required: true, description: 'lab model version id'

        def resolve(model_id:, version_id:)
          current_user = context[:current_user]

          login_required!(current_user)

          model = LabModel.find_by(id: model_id)
          raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless model.present?
          raise GraphQL::ExecutionError.new I18n.t('lab_models.forbidden') unless ::Pundit.policy(current_user, model).read?

          model_version = model.versions.find_by(id: version_id)
          raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless model_version.present?

          CustomAnalyzeServer.new({user: current_user, model: model, version: model_version}).check_task_status
        end
      end
    end
  end
end
