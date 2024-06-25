# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareSelectionType < Types::BaseObject
      field :id, Integer, null: false
      field :selection_type, Integer, description: 'selection: 0, create_repo: 1, incubation: 2'
      field :tpc_software_selection_report_ids, [String]
      field :tpc_software_selection_reports, [Types::Tpc::TpcSoftwareSelectionReportType]
      field :committers, [String]
      field :incubation_time, GraphQL::Types::ISO8601DateTime
      field :reason, String
      field :adaptation_method, Integer, description: 'adaptation: 0, rewrite: 1'
      field :created_at, GraphQL::Types::ISO8601DateTime

      def tpc_software_selection_report_ids
        object.tpc_software_selection_report_ids.present? ? JSON.parse(object.tpc_software_selection_report_ids) : []
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
