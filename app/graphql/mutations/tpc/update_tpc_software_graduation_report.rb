# frozen_string_literal: true

module Mutations
  module Tpc
    class UpdateTpcSoftwareGraduationReport < BaseMutation
      include CompassUtils

      field :status, String, null: false

      argument :report_id, Integer, required: true
      argument :software_report, Input::TpcSoftwareGraduationReportUpdateInput, required: true

      def resolve(report_id: nil, software_report: nil)
        current_user = context[:current_user]
        login_required!(current_user)

        graduation_report = TpcSoftwareGraduationReport.find_by(id: report_id)
        raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if graduation_report.nil?
        raise GraphQL::ExecutionError.new I18n.t('basic.forbidden') unless current_user&.is_admin? || graduation_report.user_id == current_user.id
        graduation_report.update!(software_report.as_json)

        { status: true, message: '' }
      rescue => ex
        { status: false, message: ex.message }
      end

    end
  end
end
