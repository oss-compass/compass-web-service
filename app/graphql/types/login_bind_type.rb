# frozen_string_literal: true

module Types
  class LoginBindType < Types::BaseObject
    field :provider, String
    field :account, String
    field :nickname, String
    field :avatar_url, String
  end
end
