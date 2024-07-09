# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareSelectionType < Types::BaseObject
      field :id, Integer, null: false
      field :selection_type, Integer, description: 'selection: 0, create_repo: 1, incubation: 2'
      field :tpc_software_selection_report_ids, [String]
      field :tpc_software_selection_reports, [Types::Tpc::TpcSoftwareSelectionReportType]
      field :repo_url, [String]
      field :committers, [String]
      field :incubation_time, String
      field :demand_source, String
      field :reason, String
      field :issue_url, String
      field :adaptation_method, String
      field :functional_description, String
      field :user_id, Integer, null: false
      field :user, Types::UserType
      field :created_at, GraphQL::Types::ISO8601DateTime

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

    end
  end
end
