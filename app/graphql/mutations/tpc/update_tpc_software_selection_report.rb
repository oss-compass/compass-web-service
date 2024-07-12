# frozen_string_literal: true

module Mutations
  module Tpc
    class UpdateTpcSoftwareSelectionReport < BaseMutation
      include CompassUtils

      field :status, String, null: false

      argument :report_id, Integer, required: true
      argument :software_report, Input::TpcSoftwareSelectionReportUpdateInput, required: true

      def resolve(report_id: nil, software_report: nil)
        current_user = context[:current_user]
        login_required!(current_user)

        selection_report = TpcSoftwareSelectionReport.find_by(id: report_id)
        raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if selection_report.nil?
        raise GraphQL::ExecutionError.new I18n.t('basic.forbidden') unless current_user&.is_admin? || selection_report.user_id == current_user.id
        selection_report.update!(software_report.as_json)

        { status: true, message: '' }
      rescue => ex
        { status: false, message: ex.message }
      end

    end
  end
end
