# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareSelectionReportType < Types::BaseObject
      field :id, Integer, null: false
      field :report_type, Integer, null: false
      field :short_code, String, null: false
      field :name, String
      field :tpc_software_sig_id, Integer
      field :tpc_software_sig, Types::Tpc::TpcSoftwareSigType
      field :tpc_software_report_metric, Types::Tpc::TpcSoftwareReportMetricType
      field :tpc_software_report_metric_raw, Types::Tpc::TpcSoftwareReportMetricRawType
      field :metric_clarification_count, Types::Tpc::TpcSoftwareReportMetricClarificationCountType
      field :metric_clarification_state, Types::Tpc::TpcSoftwareReportMetricClarificationStateType
      field :manufacturer, String
      field :website_url, String
      field :code_url, String
      field :programming_language, String
      field :code_count, Integer
      field :license, String
      field :vulnerability_disclosure, String
      field :vulnerability_response, String
      field :adaptation_method, String
      field :architecture_diagrams, [Types::ImageType]
      field :user_id, Integer, null: false
      field :user, Types::UserType
      field :report_category, Integer
      field :upstream_collaboration_strategy, Integer
      field :upstream_communication_link, String

      def user
        User.find_by(id: object.user_id)
      end

      def tpc_software_sig
        TpcSoftwareSig.find_by(id: object.tpc_software_sig_id)
      end

      def tpc_software_report_metric
        TpcSoftwareReportMetric.find_by(
          tpc_software_report_id: object.id,
          tpc_software_report_type: TpcSoftwareReportMetric::Report_Type_Selection,
          version: TpcSoftwareReportMetric::Version_Default)
      end

      def tpc_software_report_metric_raw
        report_metric = tpc_software_report_metric
        if report_metric.present?
          TpcSoftwareReportMetricRaw.find_by(tpc_software_report_metric_id: report_metric.id)
        end
      end

      def metric_clarification_count
        report_metric = tpc_software_report_metric
        clarification_count_hash = {}
        if report_metric.present?
          clarifications = TpcSoftwareComment.where(
            tpc_software_id: report_metric.id,
            tpc_software_type: TpcSoftwareComment::Type_Report_Metric
            )
          clarification_count_hash = clarifications.group_by { |item| item[:metric_name].underscore }.transform_values(&:size)
          clarification_count_hash = clarification_count_hash.transform_keys(&:to_sym)
        end
        clarification_count_hash
      end


      def metric_clarification_state
        report_metric = tpc_software_report_metric
        clarification_state_hash = {}
        if report_metric.present?
          clarifications = TpcSoftwareCommentState.where(
            tpc_software_id: report_metric.id,
            tpc_software_type: TpcSoftwareCommentState::Type_Report_Metric
            )
          clarification_state_hash = clarifications.group_by { |item| item[:metric_name].underscore }
        end
        clarification_state_hash
      end

    end
  end
end
