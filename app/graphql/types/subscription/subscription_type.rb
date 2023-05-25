# frozen_string_literal: true

module Types
  module Subscription
    class SubscriptionType < Types::BaseObject
      field :id, Integer, null: false
      field :label, String, null: false
      field :level, String, null: false
      field :status, String, null: false
      field :count, Integer, null: false
      field :status_updated_at, GraphQL::Types::ISO8601DateTime, null: false
    end
  end
end
