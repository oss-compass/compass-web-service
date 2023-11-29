# frozen_string_literal: true

module Types
  module Queries
    module Lab
      class ModelVersionReportDetailQuery < BaseQuery

        type Types::Lab::ReportType, null: true
        description 'Get thumbnail data of a lab model version reports'
        argument :model_id, Integer, required: true, description: 'lab model id'
        argument :version_id, Integer, required: true, description: 'lab model version id'
        argument :label, String, required: false, description: 'repo or project label'
        argument :short_code, String, required: false, description: 'repo or project short code'
        argument :begin_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'begin date'
        argument :end_date, GraphQL::Types::ISO8601DateTime, required: false, description: 'end date'

        def resolve(model_id:, version_id:, label: nil, short_code: nil, begin_date: nil, end_date: nil)
          current_user = context[:current_user]
          label = ShortenedLabel.normalize_label(label) if label
          label = ShortenedLabel.revert(short_code)&.label if short_code

          begin_date, end_date, interval = extract_date(begin_date, end_date)

          limit = 60

          login_required!(current_user)

          model = LabModel.find_by(id: model_id)
          raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless model.present?
          raise GraphQL::ExecutionError.new I18n.t('lab_models.forbidden') unless ::Pundit.policy(current_user, model).view?
          version = model.versions.find_by(id: version_id)
          raise GraphQL::ExecutionError.new I18n.t('lab_models.not_found') unless version.present?

          begin_date, end_date, interval = extract_date(begin_date, end_date)

          diff_seconds = end_date.to_i - begin_date.to_i

          raise GraphQL::ExecutionError.new I18n.t('lab_models.reach_limit') if diff_seconds > TWO_YEARS

          resp = CustomV1Metric.query_repo_by_date(model.id, version.id, label, begin_date, end_date, page: 1, per: limit)

          build_report_data(label, model, version, resp)
        end
      end
    end
  end
end
