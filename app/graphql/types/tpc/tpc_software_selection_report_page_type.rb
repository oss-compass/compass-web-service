# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareSelectionReportPageType < BasePageObject
      field :items, [Types::Tpc::TpcSoftwareSelectionReportType]
    end
  end
end
