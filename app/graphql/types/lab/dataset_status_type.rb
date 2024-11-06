# frozen_string_literal: true

module Types
  module Lab
    class DatasetStatusType < Types::BaseObject
      field :name, String
      field :ident, String
      field :items, [DatasetCompletionRowStatusType]
    end
  end
end
