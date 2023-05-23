# frozen_string_literal: true
module Types
  class UserType < Types::BaseObject
    field :id, Integer, null: false
    field :login_binds, [Types::LoginBindType]
    field :name, String, null: false
    field :email, String, null: false
    field :email_verified, Boolean, null: false
    field :subscriptions, Types::SubscriptionType.connection_type, null: false

    def subscriptions
      object.subscriptions.order(id: :desc)
    end

    def email_verified
      object.email_verified?
    end

    def email
      object.anonymous? ? '' : object.email
    end
  end
end
