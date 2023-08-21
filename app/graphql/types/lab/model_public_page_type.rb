# frozen_string_literal: true

module Types
  module Lab
    class ModelPublicPageType < BasePageObject
      field :items, [ModelPublicOverviewType]
    end
  end
end
