# frozen_string_literal: true

module Types
  module Queries
    module Tpc
      class TpcSoftwareReportMetricClarificationPageQuery < BaseQuery
        include Pagy::Backend

        type Types::Tpc::TpcSoftwareReportMetricClarificationPageType, null: true
        description 'Get tpc software report metric clarification page'

        argument :short_code, String, required: true
        argument :metric_name, String, required: true
        argument :page, Integer, required: false, description: 'page number'
        argument :per, Integer, required: false, description: 'per page number'

        def resolve(short_code: nil, metric_name: nil, page: 1, per: 9)
          report = TpcSoftwareSelectionReport.find_by(short_code: short_code)
          raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if report.nil?
          report_metric = TpcSoftwareReportMetric.find_by(
            tpc_software_report_id: report.id,
            tpc_software_report_type: TpcSoftwareReportMetric::Report_Type_Selection,
            version: TpcSoftwareReportMetric::Version_Default)
          raise GraphQL::ExecutionError.new I18n.t('basic.subject_not_exist') if report_metric.nil?

          items = TpcSoftwareReportMetricClarification.joins(:tpc_software_report_metric)
                                                      .where("tpc_software_report_metric_clarifications.metric_name = ?", metric_name)
                                                      .where("tpc_software_report_metric_clarifications.tpc_software_report_metric_id = ?", report_metric.id)
          pagyer, records = pagy(items, { page: page, items: per })
          { count: pagyer.count, total_page: pagyer.pages, page: pagyer.page, items: records }

        end
      end
    end
  end
end
