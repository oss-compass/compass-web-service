# frozen_string_literal: true

module Types
  module Subscription
    class SubscriptionPageType < Types::BasePageObject
      field :items, [Types::Subscription::SubscriptionType]
    end
  end
end
