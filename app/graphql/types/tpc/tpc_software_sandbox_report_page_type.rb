# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareSandboxReportPageType < BasePageObject
      field :items, [Types::Tpc::TpcSoftwareSandboxReportType]
    end
  end
end
