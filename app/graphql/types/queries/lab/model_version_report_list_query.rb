# frozen_string_literal: true

module Types
  module Queries
    module Lab
      class ModelVersionReportListQuery < BaseQuery

        type [Types::Lab::SimpleReportType], null: true
        description 'Get thumbnail data of a lab model version reports'
        argument :model_id, Integer, required: true, description: 'lab model id'
        argument :version_id, Integer, required: true, description: 'lab model version id'

        def resolve(model_id: nil, version_id: nil)
          current_user = context[:current_user]

          login_required!(current_user)

          model = LabModel.find_by(id: model_id)
          raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless model.present?
          raise GraphQL::ExecutionError.new I18n.t('lab_models.forbidden') unless ::Pundit.policy(current_user, model).view?
          version = model.versions.find_by(id: version_id)
          raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless version.present?

          begin_date, end_date, interval = extract_date(nil, nil)

          resp = CustomV1Metric.query_by_model_and_version(model.id, version.id, begin_date, end_date)
          build_simple_report_data(resp)
        end
      end
    end
  end
end
