# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareCommentPageType < BasePageObject
      field :items, [Types::Tpc::TpcSoftwareCommentType]
    end
  end
end
