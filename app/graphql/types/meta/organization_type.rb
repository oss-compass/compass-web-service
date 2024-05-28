# frozen_string_literal: true

module Types
  module Meta
    class OrganizationType < Types::BaseObject
      field :org_name, String
      field :domain, [String]
    end
  end
end
