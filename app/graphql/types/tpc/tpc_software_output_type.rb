# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareOutputType < Types::BaseObject
      field :id, Integer, null: false
      field :tpc_software_output_report_id, Integer
      field :tpc_software_output_report, Types::Tpc::TpcSoftwareOutputReportType
      field :name, String
      field :repo_url, String
      field :tpc_audit_status, Integer, description: 'reject: 0, pass: 1'
      field :tpc_audit_reason, String
      field :tpc_audit_user_id, Integer
      field :architecture_audit_status, Integer, description: 'reject: 0, pass: 1'
      field :architecture_audit_reason, String
      field :architecture_audit_user_id, Integer
      field :qa_audit_status, Integer, description: 'reject: 0, pass: 1'
      field :qa_audit_reason, String
      field :qa_audit_user_id, Integer
      field :status, Integer, description: 'process status: apply: 0, selection_audit: 1'
      field :order_num, String
      field :created_at, GraphQL::Types::ISO8601DateTime

      def tpc_software_selection_report
        TpcSoftwareSelectionReport.find_by(id: object.tpc_software_output_report_id)
      end

    end

  end
end
