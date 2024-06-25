# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareSelectionPageType < BasePageObject
      field :items, [Types::Tpc::TpcSoftwareSelectionType]
    end
  end
end
