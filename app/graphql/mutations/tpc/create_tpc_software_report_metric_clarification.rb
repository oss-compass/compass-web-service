# frozen_string_literal: true

module Mutations
  module Tpc
    class CreateTpcSoftwareReportMetricClarification < BaseMutation
      include CompassUtils

      field :status, String, null: false

      argument :short_code, String, required: true
      argument :report_type, Integer, required: false, description: '0: selection 1:graduation 3:sandbox', default_value: '0'
      argument :metric_name, String, required: true
      argument :content, String, required: true

      def resolve(short_code: nil, report_type: 0, metric_name: nil, content: nil)
        current_user = context[:current_user]
        validate_tpc!(current_user)

        tpc_software_id_list = []
        case report_type
        when TpcSoftwareMetricServer::Report_Type_Selection
          report = TpcSoftwareSelectionReport.find_by(short_code: short_code)
          raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if report.nil?
          report_metric = TpcSoftwareReportMetric.find_by(
            tpc_software_report_id: report.id,
            tpc_software_report_type: TpcSoftwareReportMetric::Report_Type_Selection,
            version: TpcSoftwareReportMetric::Version_Default)
          raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if report_metric.nil?
          tpc_software_type = TpcSoftwareComment::Type_Report_Metric
          tpc_software_list = TpcSoftwareSelection.where(target_software_report_id: report.id)
          tpc_software_list.each do |tpc_software|
            tpc_software_id_list << tpc_software.id
          end
          tpc_software_id_list.uniq
        when TpcSoftwareMetricServer::Report_Type_Graduation
          report = TpcSoftwareGraduationReport.find_by(short_code: short_code)
          raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if report.nil?
          report_metric = TpcSoftwareGraduationReportMetric.find_by(
            tpc_software_graduation_report_id: report.id,
            version: TpcSoftwareReportMetric::Version_Default)
          raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if report_metric.nil?
          tpc_software_type = TpcSoftwareComment::Type_Graduation_Report_Metric
          tpc_software_list = TpcSoftwareGraduation.where(target_software_report_id: report.id)
          tpc_software_list.each do |tpc_software|
            tpc_software_id_list << tpc_software.id
          end
          tpc_software_id_list.uniq
        when TpcSoftwareMetricServer::Report_Type_Sandbox
          report = TpcSoftwareSandboxReport.find_by(short_code: short_code)
          raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if report.nil?
          report_metric = TpcSoftwareSandboxReportMetric.find_by(
            tpc_software_sandbox_report_id: report.id,
            version: TpcSoftwareReportMetric::Version_Default)
          raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if report_metric.nil?
          tpc_software_type = TpcSoftwareComment::Type_Sandbox_Report_Metric
          tpc_software_list = TpcSoftwareSandbox.where(target_software_report_id: report.id)
          tpc_software_list.each do |tpc_software|
            tpc_software_id_list << tpc_software.id
          end
          tpc_software_id_list.uniq

        end
        ActiveRecord::Base.transaction do
          TpcSoftwareComment.create!(
            {
              tpc_software_id: report_metric.id,
              tpc_software_type: tpc_software_type,
              user_id: current_user.id,
              subject_id: report_metric.subject_id,
              metric_name: metric_name,
              content: content
            }
          )
          case report_type
          when TpcSoftwareMetricServer::Report_Type_Selection
            tpc_software = TpcSoftwareSelection
          when TpcSoftwareMetricServer::Report_Type_Graduation
            tpc_software = TpcSoftwareGraduation
          when TpcSoftwareMetricServer::Report_Type_Sandbox
            tpc_software = TpcSoftwareSandbox
          end
          tpc_software_id_list.each do |tpc_software_id|
            tpc_software.update_state(tpc_software_id)
          end
        end

        { status: true, message: '' }
      rescue => ex
        { status: false, message: ex.message }
      end

    end
  end
end
