# frozen_string_literal: true

module Mutations
  module Tpc
    class CreateTpcSoftwareOutput < BaseMutation
      include CompassUtils

    field :status, String, null: false

    argument :label, String, required: true, description: 'repo or project label'
    argument :level, String, required: false, description: 'repo or comunity', default_value: 'repo'
    argument :tpc_software_output_report_id, Integer, required: true

    def resolve(label: nil,
                level: 'repo',
                tpc_software_output_report_id: nil
                )
      label = ShortenedLabel.normalize_label(label)
      current_user = context[:current_user]
      login_required!(current_user)

      subject = Subject.find_by(label: label, level: level)
      raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if subject.nil?
      tpc_software_output_report = TpcSoftwareOutputReport.find_by(id: tpc_software_output_report_id)
      raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if tpc_software_output_report.nil?
      tpc_software_report_metric = tpc_software_output_report.tpc_software_report_metrics.find_by(
        tpc_software_report_type: TpcSoftwareReportMetric::Report_Type_Output,
        version: TpcSoftwareReportMetric::Version_Default)
      raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if tpc_software_report_metric.nil?
      raise GraphQL::ExecutionError.new I18n.t('tpc.software_report_progress') if tpc_software_report_metric.status == TpcSoftwareReportMetric::Status_Progress

      TpcSoftwareOutput.create!(
        {
          tpc_software_output_report_id: tpc_software_output_report_id,
          name: tpc_software_output_report.name,
          repo_url: tpc_software_output_report.repo_url,
          status: TpcSoftwareOutput::Status_Apply,
          order_num: get_uuid(tpc_software_output_report_id.to_s, subject.id.to_s),
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
