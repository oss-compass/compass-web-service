# frozen_string_literal: true

module Types
  module Lab
    class LabInvitationType < Types::BaseObject
      field :id, Integer, null: false
      field :email, String, null: false
      field :status, String, null: false
      field :can_read, Boolean, null: false
      field :can_update, Boolean, null: false
      field :can_execute, Boolean, null: false
      field :sent_at, GraphQL::Types::ISO8601DateTime, null: false
    end
  end
end
