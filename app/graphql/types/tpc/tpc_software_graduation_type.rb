# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareGraduationType < Types::BaseObject
      field :id, Integer, null: false
      field :tpc_software_graduation_report_ids, [Integer]
      field :tpc_software_graduation_reports, [Types::Tpc::TpcSoftwareGraduationReportType]
      field :comment_count, Integer
      field :comment_state, [Types::Tpc::TpcSoftwareCommentStateType]
      field :incubation_start_time, GraphQL::Types::ISO8601DateTime
      field :incubation_time, String
      field :demand_source, String
      field :committers, [String]
      field :functional_description, String
      field :issue_url, String
      field :comment_committer_permission, Integer, description: '1: permissioned, 0: unpermissioned'
      field :comment_sig_lead_permission, Integer, description: '1: permissioned, 0: unpermissioned'
      field :comment_legal_permission, Integer, description: '1: permissioned, 0: unpermissioned'
      field :comment_compliance_permission, Integer, description: '1: permissioned, 0: unpermissioned'
      field :user_id, Integer, null: false
      field :user, Types::UserType
      field :created_at, GraphQL::Types::ISO8601DateTime, null: false
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

      def user
        User.find_by(id: object.user_id)
      end

      def tpc_software_graduation_report_ids
        object.tpc_software_graduation_report_ids.present? ? JSON.parse(object.tpc_software_graduation_report_ids) : []
      end

      def committers
        object.committers.present? ? JSON.parse(object.committers) : []
      end

      def tpc_software_graduation_reports
        TpcSoftwareGraduationReport.where(id: tpc_software_graduation_report_ids)
      end

      def comment_count
        TpcSoftwareComment.where(
          tpc_software_id: object.id,
          tpc_software_type: TpcSoftwareCommentState::Type_Graduation,
          metric_name: TpcSoftwareCommentState::Metric_Name_Graduation
        ).count
      end

      def comment_state
        TpcSoftwareCommentState.where(
          tpc_software_id: object.id,
          tpc_software_type: TpcSoftwareCommentState::Type_Graduation,
          metric_name: TpcSoftwareCommentState::Metric_Name_Graduation
        )
      end

    end
  end
end
