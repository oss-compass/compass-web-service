# frozen_string_literal: true

module Mutations
  module Tpc
    class UpdateTpcSoftwareGraduation < BaseMutation
      include CompassUtils

    field :status, String, null: false

    argument :graduation_id, Integer, required: true
    argument :tpc_software_graduation_report_ids, [Integer], required: true
    argument :incubation_start_time, GraphQL::Types::ISO8601DateTime, required: false
    argument :incubation_time, String, required: false
    argument :demand_source, String, required: true
    argument :committers, [String], required: true
    argument :functional_description, String, required: true

    def resolve(graduation_id: nil,
                tpc_software_graduation_report_ids: [],
                incubation_start_time: nil,
                incubation_time: nil,
                demand_source: nil,
                committers: [],
                functional_description: nil
                )
      current_user = context[:current_user]
      login_required!(current_user)

      graduation = TpcSoftwareGraduation.find_by(id: graduation_id)
      raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if graduation.nil?
      raise GraphQL::ExecutionError.new I18n.t('basic.forbidden') unless current_user&.is_admin? || graduation.user_id == current_user.id
      graduation.update!(
        {
          tpc_software_graduation_report_ids: tpc_software_graduation_report_ids,
          incubation_start_time: incubation_start_time,
          incubation_time: incubation_time,
          demand_source: demand_source,
          committers: committers.any? ? committers.to_json : nil,
          functional_description: functional_description
        }
      )

      { status: true, message: '' }
    rescue => ex
      { status: false, message: ex.message }
    end
  end
  end
end
