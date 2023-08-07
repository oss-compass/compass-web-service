# frozen_string_literal: true

module Types
  class LoginBindType < Types::BaseObject
    field :provider, String
    field :account, String
    field :nickname, String
    field :avatar_url, String
  end

  def nickname
    object.nickname_after_reviewed
  end

  def avatar_url
    object.avatar_url_after_reviewed
  end
end
