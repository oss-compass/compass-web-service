# frozen_string_literal: true
module Types
  class UserType < Types::BaseObject
    field :id, Integer, null: false
    field :login_binds, [Types::LoginBindType]
    field :name, String, null: false
    field :email, String, null: false
    field :email_verified, Boolean, null: false
    field :subscriptions, Types::Subscription::SubscriptionPageType, null: false, resolver: Queries::SubscriptionsQuery
    field :language, String, null: false
    field :role_level, Integer, null: false
    field :contributing_orgs, [Types::ContributorOrgType]

    def email_verified
      object.email_verified?
    end

    def email
      object.anonymous? ? '' : object.email
    end

    def contributing_orgs
      object.contributing_orgs
    end
  end
end
