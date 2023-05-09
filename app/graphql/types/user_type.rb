# frozen_string_literal: true
module Types
  class UserType < Types::BaseObject
    field :login_binds, [Types::LoginBindType]

    def login_binds
      object.login_binds.current_host
    end
  end
end
