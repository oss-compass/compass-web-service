# frozen_string_literal: true

module Mutations
  module Tpc
    class CreateThirdSoftwareReport < BaseMutation
      include CompassUtils

      field :status, Boolean, null: false

      argument :label, String, required: true, description: 'repo or project label'
      argument :level, String, required: false, description: 'repo or community', default_value: 'repo'
      argument :software_reports, [Input::ThirdSoftwareReportInput], required: true

      def resolve(label: nil, level: 'repo', software_reports: nil)
        label = ShortenedLabel.normalize_label(label)
        current_user = context[:current_user]
        subject = Subject.find_by(label: label, level: level)

        raise GraphQL::ExecutionError.new(I18n.t('basic.subject_not_exist')) if subject.nil?

        software_reports.each_with_index do |report_input, index|
          begin
            ActiveRecord::Base.transaction do

              existing_report = TpcSoftwareSelectionReport.find_by(
                subject_id: subject.id,
                code_url: report_input.code_url
              )

              raise GraphQL::ExecutionError.new(I18n.t('tpc.software_report_already_exist')) if existing_report.present?

              report_data = report_input.as_json(except: [:architecture_diagrams])
              report_data.merge!(
                user_id: current_user.id,
                subject_id: subject.id,
                report_type: 0,
                manufacturer: "",
                website_url: "",
                tpc_software_sig_id: 13,
                programming_language: '',
                adaptation_method: '',
                short_code: TpcSoftwareSelectionReport.generate_short_code
              )


              report = TpcSoftwareSelectionReport.create!(report_data)

              report_metric = report.tpc_software_report_metrics.create!(
                code_url: report.code_url,
                status: TpcSoftwareReportMetric::Status_Progress,
                status_compass_callback: 0,
                status_tpc_service_callback: 0,
                version: TpcSoftwareReportMetric::Version_Default,
                user_id: current_user.id,
                subject_id: subject.id,
                base_repo_name: 10, # delete
                base_website_url: 10, # delete
                base_code_url: 10, # delete

                compliance_license: nil,
                compliance_dco: nil,
                compliance_license_compatibility: nil,
                ecology_patent_risk: nil, # don't do

                ecology_dependency_acquisition: nil,
                ecology_code_maintenance: nil,
                ecology_community_support: nil,
                ecology_adoption_analysis: nil, # don't do
                ecology_software_quality: nil,
                # ecology_adaptation_method

                lifecycle_version_normalization: 10, # delete
                lifecycle_version_number: 10, # delete
                lifecycle_version_lifecycle: nil,

                security_binary_artifact: nil,
                security_vulnerability: nil,
                security_vulnerability_response: 10,
                security_vulnerability_disclosure: 6, # delete
                security_history_vulnerability: nil # delete
              )


              begin
                metric_server = TpcSoftwareMetricServer.new(project_url: report.code_url)
                metric_server.analyze_metric_by_tpc_service(
                  report.id,
                  report_metric.id,
                  report.oh_commit_sha,
                  TpcSoftwareMetricServer::Report_Type_Selection
                )
                metric_server.analyze_metric_by_compass(
                  report.id,
                  report_metric.id,
                  TpcSoftwareMetricServer::Report_Type_Selection
                )
              rescue => e
                Rails.logger.error("MetricServer failed: #{e.message}")
              end

            end

          end
        end

        { status: true, message: '' }
      rescue => ex
        { status: false, message: ex.message }

      end
    end
  end
end
