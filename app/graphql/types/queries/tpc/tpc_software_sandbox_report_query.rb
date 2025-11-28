# frozen_string_literal: true

module Types
  module Queries
    module Tpc
      class TpcSoftwareSandboxReportQuery < BaseQuery
        include Pagy::Backend

        # type Types::Tpc::TpcSoftwareSelectionReportType, null: true
        type Types::Tpc::TpcSoftwareSandboxReportType, null: true
        description 'Get tpc software sandbox report apply page'
        argument :short_code, String, required: true


        def resolve(short_code: nil)

          TpcSoftwareSandboxReport.where(report_type: TpcSoftwareSandboxReport::Report_Type_Sandbox)
                                    .where("short_code = :code OR code_url = :url", code: short_code, url: short_code)
                                    .first
        end
      end
    end
  end
end
