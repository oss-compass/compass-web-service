# frozen_string_literal: true

module Mutations
  module Tpc
    class CreateTpcSoftwareSelection < BaseMutation
      include CompassUtils

    field :status, String, null: false

    argument :label, String, required: true, description: 'repo or project label'
    argument :level, String, required: false, description: 'repo or comunity', default_value: 'repo'
    argument :selection_type, Integer, required: true, description: 'selection: 0, create_repo: 1, incubation: 2'
    argument :tpc_software_selection_report_ids, [Integer], required: true
    argument :repo_url, [String], required: false
    argument :committers, [String], required: true
    argument :incubation_time, String, required: true
    argument :demand_source, String, required: false
    argument :reason, String, required: true
    argument :adaptation_method, String, required: true
    argument :functional_description, String, required: true

    def resolve(label: nil,
                level: 'repo',
                selection_type: 0,
                tpc_software_selection_report_ids: [],
                repo_url: [],
                committers: [],
                incubation_time: nil,
                demand_source: nil,
                reason: nil,
                adaptation_method: nil,
                functional_description: nil
                )
      label = ShortenedLabel.normalize_label(label)
      current_user = context[:current_user]
      login_required!(current_user)

      subject = Subject.find_by(label: label, level: level)
      raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if subject.nil?
      tpc_software_selection_report_ids.each_with_index do |report_id, index|
        tpc_software_selection_report = TpcSoftwareSelectionReport.find_by(id: report_id)
        raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if tpc_software_selection_report.nil?
        tpc_software_report_metric = tpc_software_selection_report.tpc_software_report_metrics.find_by(
          tpc_software_report_type: TpcSoftwareReportMetric::Report_Type_Selection,
          version: TpcSoftwareReportMetric::Version_Default)
        raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if tpc_software_report_metric.nil?
        raise GraphQL::ExecutionError.new I18n.t('tpc.software_report_progress') if tpc_software_report_metric.status == TpcSoftwareReportMetric::Status_Progress
      end

      TpcSoftwareSelection.create!(
        {
          selection_type: selection_type,
          tpc_software_selection_report_ids: tpc_software_selection_report_ids.any? ? tpc_software_selection_report_ids.to_json : nil,
          repo_url: repo_url.join(","),
          committers: committers.any? ? committers.to_json : nil,
          incubation_time: incubation_time,
          demand_source: demand_source,
          reason: reason,
          adaptation_method: adaptation_method,
          functional_description: functional_description,
          subject_id: subject.id,
          user_id: current_user.id
        }
      )

      { status: true, message: '' }
    rescue => ex
      { status: false, message: ex.message }
    end
  end
  end
end
