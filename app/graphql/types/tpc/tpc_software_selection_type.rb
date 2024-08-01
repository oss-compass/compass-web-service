# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareSelectionType < Types::BaseObject
      field :id, Integer, null: false
      field :selection_type, Integer, description: 'incubation: 0, sandbox: 1, graduation: 2'
      field :tpc_software_selection_report_ids, [String]
      field :tpc_software_selection_reports, [Types::Tpc::TpcSoftwareSelectionReportType]
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

      def tpc_software_selection_report_ids
        object.tpc_software_selection_report_ids.present? ? JSON.parse(object.tpc_software_selection_report_ids) : []
      end

      def repo_url
        object.repo_url.present? ? object.repo_url.split(",") : []
      end

      def committers
        object.committers.present? ? JSON.parse(object.committers) : []
      end

      def tpc_software_selection_reports
        TpcSoftwareSelectionReport.where(id: tpc_software_selection_report_ids)
      end

      def comment_count
        TpcSoftwareComment.where(
          tpc_software_id: object.id,
          tpc_software_type: TpcSoftwareCommentState::Type_Selection,
          metric_name: TpcSoftwareCommentState::Metric_Name_Selection
        ).count
      end

      def comment_state
        TpcSoftwareCommentState.where(
          tpc_software_id: object.id,
          tpc_software_type: TpcSoftwareCommentState::Type_Selection,
          metric_name: TpcSoftwareCommentState::Metric_Name_Selection
        )
      end

    end
  end
end
