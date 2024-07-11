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
      field :metric_clarification_state, [Types::Tpc::TpcSoftwareReportMetricClarificationStateType]
      field :manufacturer, String
      field :website_url, String
      field :code_url, String
      field :programming_language, String
      field :code_count, Integer
      field :license, String
      field :vulnerability_disclosure, String
      field :vulnerability_response, String
      field :is_same_type_check, Integer
      field :same_type_software_name, String
      field :user_id, Integer, null: false
      field :user, Types::UserType
      field :clarification_permission, Integer, description: '1: permissioned, 0: unpermissioned'
      field :created_at, GraphQL::Types::ISO8601DateTime, null: false
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

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
          clarifications = TpcSoftwareReportMetricClarification.where(tpc_software_report_metric_id: report_metric.id)
          clarification_count_hash = clarifications.group_by { |item| item[:metric_name].underscore }.transform_values(&:size)
          clarification_count_hash = clarification_count_hash.transform_keys(&:to_sym)
        end
        clarification_count_hash
      end


      def metric_clarification_state
        report_metric = tpc_software_report_metric
        clarifications = []
        if report_metric.present?
          clarifications = TpcSoftwareReportMetricClarificationState.where(
            tpc_software_report_metric_id: report_metric.id, state: TpcSoftwareReportMetricClarificationState::State_Accept)
        end
        clarifications
      end

    end
  end
end
