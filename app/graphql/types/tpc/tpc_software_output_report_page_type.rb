# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareOutputReportPageType < BasePageObject
      field :items, [Types::Tpc::TpcSoftwareOutputReportType]
    end
  end
end
