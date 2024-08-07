# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareSelectionSearchType < Types::BaseObject
      field :id, Integer, null: false
      field :selection_type, Integer, description: 'incubation: 0, sandbox: 1, graduation: 2'
      field :tpc_software_selection_report_ids, [String]
      field :tpc_software_selection_report, Types::Tpc::TpcSoftwareSelectionReportSearchType
      field :repo_url, [String]
      field :committers, [String]
      field :incubation_time, String
      field :demand_source, String
      field :target_software, String
      field :created_at, GraphQL::Types::ISO8601DateTime, null: false

      def tpc_software_selection_report_ids
        object.tpc_software_selection_report_ids.present? ? JSON.parse(object.tpc_software_selection_report_ids) : []
      end

      def repo_url
        object.repo_url.present? ? object.repo_url.split(",") : []
      end

      def committers
        object.committers.present? ? JSON.parse(object.committers) : []
      end

      def tpc_software_selection_report
        TpcSoftwareSelectionReport.where(id: tpc_software_selection_report_ids)
                                  .where("code_url LIKE ?", "%#{object.target_software}%")
                                  .take
      end

    end
  end
end
