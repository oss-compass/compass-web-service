# frozen_string_literal: true

module Types
  module Queries
    module Tpc
      class TpcSoftwareReportMetricClarificationPageQuery < BaseQuery
        include Pagy::Backend

        type Types::Tpc::TpcSoftwareCommentPageType, null: true
        description 'Get tpc software report metric clarification page'

        argument :short_code, String, required: true
        argument :report_type, Integer, required: false, description: '0: selection 1:graduation', default_value: '0'
        argument :metric_name, String, required: true
        argument :page, Integer, required: false, description: 'page number'
        argument :per, Integer, required: false, description: 'per page number'

        def resolve(short_code: nil, report_type: 0, metric_name: nil, page: 1, per: 9)
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
          when TpcSoftwareMetricServer::Report_Type_Graduation
            report = TpcSoftwareGraduationReport.find_by(short_code: short_code)
            raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if report.nil?
            report_metric = TpcSoftwareGraduationReportMetric.find_by(
              tpc_software_graduation_report_id: report.id,
              version: TpcSoftwareGraduationReportMetric::Version_Default)
            raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if report_metric.nil?
            tpc_software_type = TpcSoftwareComment::Type_Graduation_Report_Metric
          end

          items = TpcSoftwareComment.where("metric_name = ?", metric_name)
                                    .where("tpc_software_type = ?", tpc_software_type)
                                    .where("tpc_software_id = ?", report_metric.id)

          pagyer, records = pagy(items, { page: page, items: per })
          { count: pagyer.count, total_page: pagyer.pages, page: pagyer.page, items: records }

        end
      end
    end
  end
end
