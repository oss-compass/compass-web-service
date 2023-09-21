# frozen_string_literal: true

module Types
  module Lab
    class MyModelsType < BasePageObject
      field :items, [Types::Lab::ModelDetailType]
    end
  end
end
