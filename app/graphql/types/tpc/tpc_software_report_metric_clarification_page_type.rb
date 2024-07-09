# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareReportMetricClarificationPageType < BasePageObject
      field :items, [Types::Tpc::TpcSoftwareReportMetricClarificationType]
    end
  end
end
