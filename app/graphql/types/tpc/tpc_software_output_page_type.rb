# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareOutputPageType < BasePageObject
      field :items, [Types::Tpc::TpcSoftwareOutputType]
    end
  end
end
