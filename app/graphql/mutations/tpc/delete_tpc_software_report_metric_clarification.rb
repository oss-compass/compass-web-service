# frozen_string_literal: true

module Mutations
  module Tpc
    class DeleteTpcSoftwareReportMetricClarification < BaseMutation
      include CompassUtils

      field :status, String, null: false

      argument :clarification_id, Integer, required: true

      def resolve(clarification_id: nil)
        current_user = context[:current_user]
        login_required!(current_user)

        clarification = TpcSoftwareReportMetricClarification.find_by(id: clarification_id)
        raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if clarification.nil?
        raise GraphQL::ExecutionError.new I18n.t('basic.forbidden') unless current_user&.is_admin? || clarification.user_id == current_user.id
        clarification.destroy!

        { status: true, message: '' }
      rescue => ex
        { status: false, message: ex.message }
      end

    end
  end
end
