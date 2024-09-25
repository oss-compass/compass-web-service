# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareMyCreationAndReviewPageType < BasePageObject
      field :items, [Types::Tpc::TpcSoftwareMyCreationAndReviewType]
    end
  end
end
