# frozen_string_literal: true

module Types
  module Subscription
    class SubjectSubscriptionCountType < Types::BaseObject
      field :count, Integer, null: false
      field :subscribed, Boolean, null: false
    end
  end
end
