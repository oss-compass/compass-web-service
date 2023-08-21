# frozen_string_literal: true

module Types
  module Lab
    class MyModelsType < Types::BaseObject
      field :count, Integer
      field :total_page, Integer
      field :page, Integer
      field :items, [Types::Lab::ModelDetailType]
    end
  end
end
