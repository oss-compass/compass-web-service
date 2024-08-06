# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareGraduationPageType < BasePageObject
      field :items, [Types::Tpc::TpcSoftwareGraduationType]
    end
  end
end
