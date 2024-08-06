# frozen_string_literal: true

module Mutations
  module Tpc
    class CreateTpcSoftwareGraduation < BaseMutation
      include CompassUtils

    field :status, String, null: false
    field :id, Integer, null: false

    argument :label, String, required: true, description: 'repo or project label'
    argument :level, String, required: false, description: 'repo or community', default_value: 'repo'
    argument :tpc_software_graduation_report_ids, [Integer], required: true
    argument :incubation_start_time, GraphQL::Types::ISO8601DateTime, required: false
    argument :incubation_time, String, required: false
    argument :demand_source, String, required: true
    argument :committers, [String], required: true
    def resolve(label: nil,
                level: 'repo',
                tpc_software_graduation_report_ids: [],
                incubation_start_time: nil,
                incubation_time: nil,
                demand_source: nil,
                committers: []
                )
      label = ShortenedLabel.normalize_label(label)
      current_user = context[:current_user]
      validate_tpc!(current_user)

      subject = Subject.find_by(label: label, level: level)
      raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if subject.nil?
      tpc_software_graduation_report_ids.each_with_index do |report_id, index|
        tpc_software_graduation_report = TpcSoftwareGraduationReport.find_by(id: report_id)
        raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if tpc_software_graduation_report.nil?
        tpc_software_report_metric = tpc_software_graduation_report.tpc_software_graduation_report_metrics.find_by(version: TpcSoftwareReportMetric::Version_Default)
        raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if tpc_software_report_metric.nil?
        raise GraphQL::ExecutionError.new I18n.t('tpc.software_report_progress') if tpc_software_report_metric.status == TpcSoftwareGraduationReportMetric::Status_Progress
      end

      graduation = TpcSoftwareGraduation.create!(
        {
          tpc_software_graduation_report_ids: tpc_software_graduation_report_ids.any? ? tpc_software_graduation_report_ids.to_json : nil,
          incubation_start_time: incubation_start_time,
          incubation_time: incubation_time,
          demand_source: demand_source,
          committers: committers.any? ? committers.to_json : nil,
          subject_id: subject.id,
          user_id: current_user.id
        }
      )

      { status: true, id: graduation.id, message: '' }
    rescue => ex
      { status: false, id: '', message: ex.message }
    end
  end
  end
end
