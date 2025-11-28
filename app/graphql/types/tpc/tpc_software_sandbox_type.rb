# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareSandboxType < Types::BaseObject
      field :id, Integer, null: false
      # field :selection_type, Integer, description: 'incubation: 0, sandbox: 1, graduation: 2'
      field :tpc_software_sandbox_report_ids, [String]
      field :tpc_software_sandbox_reports, [Types::Tpc::TpcSoftwareSandboxReportType]
      field :comment_count, Integer
      field :comment_state, [Types::Tpc::TpcSoftwareCommentStateType]
      field :repo_url, [String]
      field :committers, [String]
      field :incubation_time, String
      field :demand_source, String
      field :reason, String
      field :issue_url, String
      field :functional_description, String
      field :target_software, String
      field :is_same_type_check, Integer
      field :same_type_software_name, String
      field :state, Integer, description: '0: awaiting_clarification 1: awaiting_confirmation 2: awaiting_review 3: completed -1:rejected'
      field :comment_committer_permission, Integer, description: '1: permissioned, 0: unpermissioned'
      field :comment_sig_lead_permission, Integer, description: '1: permissioned, 0: unpermissioned'
      field :comment_legal_permission, Integer, description: '1: permissioned, 0: unpermissioned'
      field :comment_compliance_permission, Integer, description: '1: permissioned, 0: unpermissioned'
      field :comment_qa_permission, Integer, description: '1: permissioned, 0: unpermissioned'
      field :comment_community_collaboration_wg_permission, Integer, description: '1: permissioned, 0: unpermissioned'
      field :user_id, Integer, null: false
      field :user, Types::UserType

      field :risk_count, Integer
      field :awaiting_clarification_count, Integer
      field :clarified_count, Integer
      field :awaiting_confirmation_count, Integer
      field :confirmed_count, Integer

      field :committer_count, Integer
      field :sig_lead_count, Integer
      field :legal_count, Integer
      field :compliance_count, Integer

      field :created_at, GraphQL::Types::ISO8601DateTime, null: false
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

      def user
        User.find_by(id: object.user_id)
      end

      def tpc_software_sandbox_report_ids
        object.tpc_software_sandbox_report_ids.present? ? JSON.parse(object.tpc_software_sandbox_report_ids) : []
      end

      def repo_url
        object.repo_url.present? ? object.repo_url.split(",") : []
      end

      def committers
        object.committers.present? ? JSON.parse(object.committers) : []
      end

      def tpc_software_sandbox_reports
        TpcSoftwareSandboxReport.where(id: tpc_software_sandbox_report_ids)
      end

      def comment_count
        TpcSoftwareComment.where(
          tpc_software_id: object.id,
          tpc_software_type: TpcSoftwareCommentState::Type_Sandbox,
          metric_name: TpcSoftwareCommentState::Metric_Name_Sandbox
        ).count
      end

      def comment_state
        TpcSoftwareCommentState.where(
          tpc_software_id: object.id,
          tpc_software_type: TpcSoftwareCommentState::Type_Sandbox,
          metric_name: TpcSoftwareCommentState::Metric_Name_Sandbox
        )
      end


      def risk_count
        TpcSoftwareSandbox.get_risk_metric_list(object.target_software_report_id).length
      end


      def awaiting_clarification_count
        risk_count - clarified_count
      end


      def clarified_count
        TpcSoftwareSandbox.get_clarified_metric_list(object.target_software_report_id).length
      end

      def awaiting_confirmation_count
        risk_count - confirmed_count
      end

      def confirmed_count
        TpcSoftwareSandbox.get_confirmed_metric_list(object.target_software_report_id).length
      end


      def committer_count
        get_member_count(TpcSoftwareCommentState::Member_Type_Committer)
      end

      def sig_lead_count
        get_member_count(TpcSoftwareCommentState::Member_Type_Sig_Lead)
      end

      def legal_count
        get_member_count(TpcSoftwareCommentState::Member_Type_Legal)
      end

      def compliance_count
        get_member_count(TpcSoftwareCommentState::Member_Type_Compliance)
      end

      def get_member_count(member_type)
        TpcSoftwareSandbox.get_comment_state_list(object.id).where(member_type: member_type).count
      end

    end
  end
end
