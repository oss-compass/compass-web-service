# frozen_string_literal: true

module Types
  module Lab
    class LabMemberType < Types::BaseObject
      field :id, Integer, null: false
      field :name, String, null: false
      field :avatar_url, String
      field :is_owner, Boolean, null: false
      field :can_read, Boolean, null: false
      field :can_update, Boolean, null: false
      field :can_execute, Boolean, null: false
      field :joined_at, GraphQL::Types::ISO8601DateTime, null: false
    end
  end
end
