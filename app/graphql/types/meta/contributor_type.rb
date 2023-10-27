# frozen_string_literal: true

module Types
  module Meta
    class ContributorType < Types::BaseObject
      field :name, String
      field :type, String
      field :origin, String
      field :value, Float
    end
  end
end
