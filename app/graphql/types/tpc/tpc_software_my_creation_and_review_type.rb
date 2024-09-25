# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareMyCreationAndReviewType < Types::BaseObject
      field :id, Integer
      field :target_software_report_id, Integer
      field :application_type, Integer, description: '0: incubation 1: graduation'
      field :issue_url, String
      field :name, String
      field :state, Integer
      field :user_id, Integer
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

      field :created_at, GraphQL::Types::ISO8601DateTime
      field :updated_at, GraphQL::Types::ISO8601DateTime

      def user
        User.find_by(id: object.user_id)
      end

      def name
        case object.application_type
        when 0
          report = TpcSoftwareSelectionReport.find_by(id: object.target_software_report_id)
        when 1
          report = TpcSoftwareGraduationReport.find_by(id: object.target_software_report_id)
        else
          report = TpcSoftwareSelectionReport.find_by(id: object.target_software_report_id)
        end
        if report.present?
          return report.name
        end
        nil
      end


      def risk_count
        case object.application_type
        when 0
          risk_metric_list = TpcSoftwareSelection.get_risk_metric_list(object.target_software_report_id)
        when 1
          risk_metric_list = TpcSoftwareGraduation.get_risk_metric_list(object.target_software_report_id)
        else
          risk_metric_list = TpcSoftwareSelection.get_risk_metric_list(object.target_software_report_id)
        end
        risk_metric_list.length
      end


      def awaiting_clarification_count
        risk_count - clarified_count
      end


      def clarified_count
        case object.application_type
        when 0
          clarified_metric_list = TpcSoftwareSelection.get_clarified_metric_list(object.target_software_report_id)
        when 1
          clarified_metric_list = TpcSoftwareGraduation.get_clarified_metric_list(object.target_software_report_id)
        else
          clarified_metric_list = TpcSoftwareSelection.get_clarified_metric_list(object.target_software_report_id)
        end
        clarified_metric_list.length
      end

      def awaiting_confirmation_count
        risk_count - confirmed_count
      end

      def confirmed_count
        case object.application_type
        when 0
          confirmed_metric_list = TpcSoftwareSelection.get_confirmed_metric_list(object.target_software_report_id)
        when 1
          confirmed_metric_list = TpcSoftwareGraduation.get_confirmed_metric_list(object.target_software_report_id)
        else
          confirmed_metric_list = TpcSoftwareSelection.get_confirmed_metric_list(object.target_software_report_id)
        end
        confirmed_metric_list.length
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
        case object.application_type
        when 0
          metric_name = TpcSoftwareCommentState::Metric_Name_Selection
        when 1
          metric_name = TpcSoftwareCommentState::Metric_Name_Graduation
        else
          metric_name = TpcSoftwareCommentState::Metric_Name_Selection
        end
        TpcSoftwareCommentState.where(tpc_software_id: object.id)
                               .where(metric_name: metric_name)
                               .where(member_type: member_type)
                               .count
      end





    end
  end
end
