# frozen_string_literal: true
module Types
  class ContributorOrgType < Types::BaseObject
    field :org_name, String, description: "organization's name"
    field :first_date, GraphQL::Types::ISO8601DateTime, description: 'time of begin of service by the organization'
    field :last_date, GraphQL::Types::ISO8601DateTime, description: 'time of end of service by the organization'
    field :platform_type, String, description: 'platform type of the organization'
  end
end
