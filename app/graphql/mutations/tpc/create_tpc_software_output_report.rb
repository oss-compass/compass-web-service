# frozen_string_literal: true

module Mutations
  module Tpc
    class CreateTpcSoftwareOutputReport < BaseMutation

    field :status, String, null: false

    argument :label, String, required: true, description: 'repo or project label'
    argument :level, String, required: false, description: 'repo or comunity', default_value: 'repo'
    argument :software_report, Input::TpcSoftwareOutputReportInput, required: true

    def resolve(label: nil,
                level: 'repo',
                software_report: nil
                )
      label = ShortenedLabel.normalize_label(label)
      current_user = context[:current_user]
      login_required!(current_user)

      subject = Subject.find_by(label: label, level: level)
      raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if subject.nil?
      tpc_software_selection = TpcSoftwareSelection.find_by(order_num: software_report.tpc_software_selection_order_num)
      raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if tpc_software_selection.nil?

      ActiveRecord::Base.transaction do
        software_report_data = software_report.as_json
        software_report_data["user_id"] = current_user.id
        software_report_data["subject_id"] = subject.id
        software_report_data["tpc_software_selection_id"] = tpc_software_selection.id
        tpc_software_output_report = TpcSoftwareOutputReport.create!(software_report_data)

        tpc_software_output_report.tpc_software_report_metrics.create!(
          {
            status: TpcSoftwareReportMetric::Status_Success,
            version: TpcSoftwareReportMetric::Version_Default,
            user_id: current_user.id,
            subject_id: subject.id,
            compliance_license: 5,
            compliance_dco: 5,
            compliance_package_sig: 5,
            ecology_dependency_acquisition: 5,
            ecology_code_maintenance: 5,
            ecology_community_support: 5,
            ecology_adoption_analysis: 5,
            ecology_software_quality: 5,
            ecology_patent_risk: 5,
            lifecycle_version_normalization: 5,
            lifecycle_version_number: 5,
            lifecycle_version_lifecycle: 5,
            security_binary_artifact: 5,
            security_vulnerability: 5,
            security_vulnerability_response: 5,
            security_vulnerability_disclosure: 5,
            security_history_vulnerability: 5
          }
        )

      end

      { status: true, message: '' }
    rescue => ex
      { status: false, message: ex.message }
    end
  end
  end
end
