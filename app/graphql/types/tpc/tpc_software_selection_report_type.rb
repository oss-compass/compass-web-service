# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareSelectionReportType < Types::BaseObject
      field :id, Integer, null: false
      field :report_type, Integer, null: false
      field :short_code, String, null: false
      field :name, String
      field :tpc_software_sig_id, Integer
      field :tpc_software_sig, Types::Tpc::TpcSoftwareSigType
      field :tpc_software_report_metric, Types::Tpc::TpcSoftwareReportMetricType
      field :release, String
      field :release_time, GraphQL::Types::ISO8601DateTime
      field :manufacturer, String
      field :website_url, String
      field :code_url, String
      field :programming_language, String
      field :code_count, Integer
      field :license, String
      field :vulnerability_disclosure, String
      field :vulnerability_response, String
      field :user_id, Integer, null: false
      field :user, Types::UserType

      def user
        User.find_by(id: object.user_id)
      end

      def tpc_software_sig
        TpcSoftwareSig.find_by(id: object.tpc_software_sig_id)
      end

      def tpc_software_report_metric
        TpcSoftwareReportMetric.find_by(
          tpc_software_report_id: object.id,
          tpc_software_report_type: TpcSoftwareReportMetric::Report_Type_Selection,
          version: TpcSoftwareReportMetric::Version_Default)
      end

    end
  end
end
