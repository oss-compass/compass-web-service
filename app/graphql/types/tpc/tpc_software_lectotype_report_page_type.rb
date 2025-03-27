# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareLectotypeReportPageType < BasePageObject
      field :items, [Types::Tpc::TpcSoftwareLectotypeReportType]
    end
  end
end
