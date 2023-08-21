# frozen_string_literal: true

module Types
  module Lab
    class AlgorithmType < Types::BaseObject
      field :name, String, null: false
      field :ident, String, null: false
    end
  end
end
