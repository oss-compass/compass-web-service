# frozen_string_literal: true
module Types
  class SimpleUserType < Types::BaseObject
    field :id, Integer, null: false
    field :name, String, null: false
    field :avatar_url, String
  end
end
