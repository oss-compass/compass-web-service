# frozen_string_literal: true

module Types
  module Queries
    module Tpc
      class TpcSoftwareSelectionReportQuery < BaseQuery
        include Pagy::Backend

        type Types::Tpc::TpcSoftwareSelectionReportType, null: true
        description 'Get tpc software selection report apply page'
        argument :short_code, String, required: true


        def resolve(short_code: nil)
          TpcSoftwareSelectionReport.where(report_type: TpcSoftwareSelectionReport::Report_Type_Incubation)
                                    .where("short_code = :code OR code_url = :url", code: short_code, url: short_code)
                                    .first
        end
      end
    end
  end
end
