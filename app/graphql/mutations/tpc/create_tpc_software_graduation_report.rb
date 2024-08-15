# frozen_string_literal: true

module Mutations
  module Tpc
    class CreateTpcSoftwareGraduationReport < BaseMutation
      include CompassUtils

      field :status, String, null: false

      argument :label, String, required: true, description: 'repo or project label'
      argument :level, String, required: false, description: 'repo or community', default_value: 'repo'
      argument :software_report, Input::TpcSoftwareGraduationReportInput, required: true

      def resolve(label: nil, level: 'repo', software_report: nil)
        label = ShortenedLabel.normalize_label(label)
        current_user = context[:current_user]
        validate_tpc!(current_user)

        architecture_diagrams = software_report.architecture_diagrams || []
        raise GraphQL::ExecutionError.new I18n.t('lab_models.reach_limit') if architecture_diagrams.length > 5

        subject = Subject.find_by(label: label, level: level)
        raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if subject.nil?
        tpc_software_graduation_report = TpcSoftwareGraduationReport.find_by(subject_id: subject.id, code_url: software_report.code_url)
        raise GraphQL::ExecutionError.new I18n.t('tpc.software_report_already_exist') if tpc_software_graduation_report.present?
        raise GraphQL::ExecutionError.new I18n.t('tpc.software_code_url_invalid') unless TpcSoftwareGraduationReportMetric.check_url(software_report.code_url)

        ActiveRecord::Base.transaction do
          software_report_data = software_report.as_json(except: [:architecture_diagrams])
          software_report_data["user_id"] = current_user.id
          software_report_data["subject_id"] = subject.id
          software_report_data["short_code"] = TpcSoftwareGraduationReport.generate_short_code
          report = TpcSoftwareGraduationReport.create(software_report_data)
          architecture_diagrams.each do |architecture_diagram|
            report.architecture_diagrams.attach(data: architecture_diagram.base64, filename: architecture_diagram.filename)
          end
          report.save!

          report_metric = report.tpc_software_graduation_report_metrics.create!(
            {
              code_url: report.code_url,
              status: TpcSoftwareGraduationReportMetric::Status_Progress,
              status_compass_callback: 0,
              status_tpc_service_callback: 0,
              version: TpcSoftwareGraduationReportMetric::Version_Default,
              user_id: current_user.id,
              subject_id: subject.id,

              compliance_license: nil,
              compliance_dco: nil,
              compliance_license_compatibility: nil,
              compliance_copyright_statement: nil,
              compliance_copyright_statement_anti_tamper: nil, #don't do
              compliance_snippet_reference: nil, #don't do

              ecology_readme: nil,
              ecology_build_doc: nil,
              ecology_interface_doc: nil,
              ecology_issue_management: nil,
              ecology_issue_response_ratio: nil,
              ecology_issue_response_time: nil,
              ecology_maintainer_doc: nil,
              ecology_build: nil, #don't do
              ecology_ci: nil, #don't do
              ecology_test_coverage: nil,
              ecology_code_review: nil,
              ecology_code_upstream: software_report.round_upstream.present? ? 10 : 0,

              lifecycle_release_note: nil,
              lifecycle_statement: software_report.lifecycle_policy.present? ? 10 : 0,

              security_binary_artifact: nil,
              security_vulnerability: nil,
              security_package_sig: nil
            }
          )

          metric_server = TpcSoftwareMetricServer.new({project_url: software_report.code_url})
          metric_server.analyze_metric_by_tpc_service(report.id, report_metric.id, TpcSoftwareMetricServer::Report_Type_Graduation)
          metric_server.analyze_metric_by_compass(report.id, report_metric.id, TpcSoftwareMetricServer::Report_Type_Graduation)
        end


        { status: true, message: '' }
      rescue => ex
        { status: false, message: ex.message }
      end

    end
  end
end
