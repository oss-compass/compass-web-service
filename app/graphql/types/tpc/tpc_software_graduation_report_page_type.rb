# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareGraduationReportPageType < BasePageObject
      field :items, [Types::Tpc::TpcSoftwareGraduationReportType]
    end
  end
end
