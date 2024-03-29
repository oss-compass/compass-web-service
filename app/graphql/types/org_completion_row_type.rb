# frozen_string_literal: true

module Types
  class OrgCompletionRowType < Types::BaseObject
    field :org_name, String, description: 'organization name'
  end
end
