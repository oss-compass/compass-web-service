# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareOutputReportType < Types::BaseObject
      field :id, Integer, null: false
      field :name, String
      field :tpc_software_selection_order_num, String
      field :tpc_software_sig_id, Integer
      field :tpc_software_sig, Types::Tpc::TpcSoftwareSigType
      field :tpc_software_report_metric, Types::Tpc::TpcSoftwareReportMetricType
      field :repo_url, String
      field :reason, String

      def tpc_software_sig
        TpcSoftwareSig.find_by(id: object.tpc_software_sig_id)
      end

      def tpc_software_report_metric
        TpcSoftwareReportMetric.find_by(
          tpc_software_report_id: object.id,
          tpc_software_report_type: TpcSoftwareReportMetric::Report_Type_Output,
          version: TpcSoftwareReportMetric::Version_Default)
      end

    end
  end
end
