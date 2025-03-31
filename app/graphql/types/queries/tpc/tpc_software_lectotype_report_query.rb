# frozen_string_literal: true

module Types
  module Queries
    module Tpc
      class TpcSoftwareLectotypeReportQuery < BaseQuery
        include Pagy::Backend

        type Types::Tpc::TpcSoftwareLectotypeReportType, null: true
        description 'Get tpc software lectotype report apply page'
        argument :short_code, String, required: true


        def resolve(short_code: nil)
          TpcSoftwareLectotypeReport.where("short_code = :code OR code_url = :url", code: short_code, url: short_code)
                                    .first
        end
      end
    end
  end
end
