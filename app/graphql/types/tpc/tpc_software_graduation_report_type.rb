# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareGraduationReportType < Types::BaseObject
      field :id, Integer, null: false
      field :short_code, String, null: false
      field :name, String
      field :tpc_software_sig_id, Integer
      field :tpc_software_sig, Types::Tpc::TpcSoftwareSigType
      field :graduation_report_metric, Types::Tpc::TpcSoftwareGraduationReportMetricType
      field :graduation_report_metric_raw, Types::Tpc::TpcSoftwareGraduationReportMetricRawType
      field :metric_clarification_count, Types::Tpc::TpcSoftwareGraduationReportMetricClarificationCountType
      field :metric_clarification_state, Types::Tpc::TpcSoftwareGraduationReportMetricClarificationStateType
      field :code_url, String
      field :upstream_code_url, String
      field :programming_language, String
      field :adaptation_method, String
      field :lifecycle_policy, String
      field :round_upstream, String
      field :license, String
      field :code_count, Integer
      field :user_id, Integer, null: false
      field :user, Types::UserType
      field :clarification_committer_permission, Integer, description: '1: permissioned, 0: unpermissioned'
      field :clarification_sig_lead_permission, Integer, description: '1: permissioned, 0: unpermissioned'
      field :clarification_legal_permission, Integer, description: '1: permissioned, 0: unpermissioned'
      field :clarification_compliance_permission, Integer, description: '1: permissioned, 0: unpermissioned'

      def user
        User.find_by(id: object.user_id)
      end

      def tpc_software_sig
        TpcSoftwareSig.find_by(id: object.tpc_software_sig_id)
      end

      def graduation_report_metric
        TpcSoftwareGraduationReportMetric.find_by(
          tpc_software_graduation_report_id: object.id,
          version: TpcSoftwareReportMetric::Version_Default)
      end

      def graduation_report_metric_raw
        report_metric = graduation_report_metric
        if report_metric.present?
          TpcSoftwareGraduationReportMetricRaw.find_by(tpc_software_graduation_report_metric_id: report_metric.id)
        end
      end

      def metric_clarification_count
        report_metric = graduation_report_metric
        clarification_count_hash = {}
        if report_metric.present?
          clarifications = TpcSoftwareComment.where(
            tpc_software_id: report_metric.id,
            tpc_software_type: TpcSoftwareComment::Type_Graduation_Report_Metric
            )
          clarification_count_hash = clarifications.group_by { |item| item[:metric_name].underscore }.transform_values(&:size)
          clarification_count_hash = clarification_count_hash.transform_keys(&:to_sym)
        end
        clarification_count_hash
      end


      def metric_clarification_state
        report_metric = graduation_report_metric
        clarification_state_hash = {}
        if report_metric.present?
          clarifications = TpcSoftwareCommentState.where(
            tpc_software_id: report_metric.id,
            tpc_software_type: TpcSoftwareCommentState::Type_Graduation_Report_Metric
            )
          clarification_state_hash = clarifications.group_by { |item| item[:metric_name].underscore }
        end
        clarification_state_hash
      end

    end
  end
end
