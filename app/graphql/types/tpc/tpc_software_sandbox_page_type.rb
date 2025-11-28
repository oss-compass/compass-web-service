# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareSandboxPageType < BasePageObject
      field :items, [Types::Tpc::TpcSoftwareSandboxType]
    end
  end
end
