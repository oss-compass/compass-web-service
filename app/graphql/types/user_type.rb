# frozen_string_literal: true
module Types
  class UserType < Types::BaseObject
    field :login_binds, [Types::LoginBindType]
    field :name, String, null: false
    field :email, String, null: false
    field :email_verified, Boolean, null: false

    def email_verified
      object.email_verified?
    end

    def email
      object.anonymous? ? '' : object.email
    end

    def login_binds
      object.login_binds.current_host
    end
  end
end
