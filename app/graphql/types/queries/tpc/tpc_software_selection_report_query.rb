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
          TpcSoftwareSelectionReport.find_by(short_code: short_code)
        end
      end
    end
  end
end
