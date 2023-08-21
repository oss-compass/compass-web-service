# frozen_string_literal: true

module Types
  module Lab
    class DatasetType < Types::BaseObject
      field :name, String
      field :ident, String
      field :items, [DatasetCompletionRowType]
    end
  end
end
