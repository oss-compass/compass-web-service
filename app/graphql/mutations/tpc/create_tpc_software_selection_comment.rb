# frozen_string_literal: true

module Mutations
  module Tpc
    class CreateTpcSoftwareSelectionComment < BaseMutation
      include CompassUtils

      field :status, String, null: false

      argument :selection_id, Integer, required: true
      argument :report_type, Integer, required: false, description: '0: selection 1:graduation', default_value: '0'
      argument :content, String, required: true

      def resolve(selection_id: nil, report_type: 0,content: nil)
        current_user = context[:current_user]
        validate_tpc!(current_user)

        case report_type
        when TpcSoftwareMetricServer::Report_Type_Selection
          selection = TpcSoftwareSelection.find_by(id: selection_id)
          raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if selection.nil?
          tpc_software_type = TpcSoftwareComment::Type_Selection
          metric_name = TpcSoftwareComment::Metric_Name_Selection
        when TpcSoftwareMetricServer::Report_Type_Graduation
          selection = TpcSoftwareGraduation.find_by(id: selection_id)
          raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if selection.nil?
          tpc_software_type = TpcSoftwareComment::Type_Graduation
          metric_name = TpcSoftwareComment::Metric_Name_Graduation
        end

        TpcSoftwareComment.create!(
          {
            tpc_software_id: selection.id,
            tpc_software_type: tpc_software_type,
            user_id: current_user.id,
            subject_id: selection.subject_id,
            metric_name: metric_name,
            content: content
          }
        )

        { status: true, message: '' }
      rescue => ex
        { status: false, message: ex.message }
      end

    end
  end
end
