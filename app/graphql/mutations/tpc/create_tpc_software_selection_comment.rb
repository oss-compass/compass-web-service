# frozen_string_literal: true

module Mutations
  module Tpc
    class CreateTpcSoftwareSelectionComment < BaseMutation
      include CompassUtils

      field :status, String, null: false

      argument :selection_id, Integer, required: true
      argument :content, String, required: true

      def resolve(selection_id: nil, content: nil)
        current_user = context[:current_user]
        validate_tpc!(current_user)

        selection = TpcSoftwareSelection.find_by(id: selection_id)
        raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if selection.nil?

        TpcSoftwareComment.create!(
          {
            tpc_software_id: selection.id,
            tpc_software_type: TpcSoftwareComment::Type_Selection,
            user_id: current_user.id,
            subject_id: selection.subject_id,
            metric_name: TpcSoftwareComment::Metric_Name_Selection,
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
