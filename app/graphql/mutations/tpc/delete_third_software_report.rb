# frozen_string_literal: true

module Mutations
  module Tpc
    class DeleteThirdSoftwareReport < BaseMutation


      include CompassUtils

      argument :report_id, Integer, required: true

      def resolve(report_id: nil)
        current_user = context[:current_user]
        login_required!(current_user)

        report = TpcSoftwareSelectionReport.find_by(id: report_id)
        raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if report.nil?
        raise GraphQL::ExecutionError.new I18n.t('basic.forbidden') unless current_user&.is_admin? || report.user_id == current_user.id
        report.destroy!

        { status: true, message: '' }
      rescue => ex
        { status: false, message: ex.message }
      end

    end
  end
end
