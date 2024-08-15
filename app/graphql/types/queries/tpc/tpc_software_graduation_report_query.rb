# frozen_string_literal: true

module Types
  module Queries
    module Tpc
      class TpcSoftwareGraduationReportQuery < BaseQuery
        include Pagy::Backend

        type Types::Tpc::TpcSoftwareGraduationReportType, null: true
        description 'Get tpc software graduation report apply page'
        argument :short_code, String, required: true


        def resolve(short_code: nil)
          TpcSoftwareGraduationReport.find_by(short_code: short_code)
        end
      end
    end
  end
end
