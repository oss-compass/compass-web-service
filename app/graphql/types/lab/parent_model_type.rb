# frozen_string_literal: true

module Types
  module Lab
    class ParentModelType < Types::BaseObject
      field :id, Integer, null: false
      field :name, String, null: false
      field :description, String
      field :is_public, Boolean, null: false
      field :user_id, Integer, null: false
      field :login_binds, Types::LoginBindType
      field :created_at, GraphQL::Types::ISO8601DateTime
      def login_binds
        LoginBind.find_by(user_id: object.user_id)

      end

    end
  end
end
