# frozen_string_literal: true

module Mutations
  module Tpc
    class UpdateTpcSoftwareSelection < BaseMutation
      include CompassUtils

    field :status, String, null: false

    argument :selection_id, Integer, required: true
    argument :tpc_software_selection_report_ids, [Integer], required: true
    argument :repo_url, [String], required: false
    argument :committers, [String], required: true
    argument :incubation_time, String, required: true
    argument :demand_source, String, required: false
    argument :reason, String, required: true
    argument :adaptation_method, String, required: true
    argument :functional_description, String, required: true
    argument :target_software, String, required: true
    argument :is_same_type_check, Integer, required: true
    argument :same_type_software_name, String, required: false

    def resolve(selection_id: nil,
                tpc_software_selection_report_ids: [],
                repo_url: [],
                committers: [],
                incubation_time: nil,
                demand_source: nil,
                reason: nil,
                adaptation_method: nil,
                functional_description: nil,
                target_software: nil,
                is_same_type_check: 0,
                same_type_software_name: nil
                )
      current_user = context[:current_user]
      login_required!(current_user)

      selection = TpcSoftwareSelection.find_by(id: selection_id)
      raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if selection.nil?
      raise GraphQL::ExecutionError.new I18n.t('basic.forbidden') unless current_user&.is_admin? || selection.user_id == current_user.id
      selection.update!(
        {
          tpc_software_selection_report_ids: tpc_software_selection_report_ids.any? ? tpc_software_selection_report_ids.to_json : nil,
          repo_url: repo_url.join(","),
          committers: committers.any? ? committers.to_json : nil,
          incubation_time: incubation_time,
          demand_source: demand_source,
          reason: reason,
          adaptation_method: adaptation_method,
          functional_description: functional_description,
          target_software: target_software,
          is_same_type_check: is_same_type_check,
          same_type_software_name: same_type_software_name,
        }
      )

      { status: true, message: '' }
    rescue => ex
      { status: false, message: ex.message }
    end
  end
  end
end
