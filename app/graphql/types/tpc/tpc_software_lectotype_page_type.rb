# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareLectotypePageType < BasePageObject
      field :items, [Types::Tpc::TpcSoftwareLectotypeType]
    end
  end
end
