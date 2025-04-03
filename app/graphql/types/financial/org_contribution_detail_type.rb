# frozen_string_literal: true

module Types
  module Financial
    class OrgContributionDetailType < BaseObject

      field :repo_url, String, null: true
      field :org_contribution_details, ContributionDetailType, null: true

    end
  end
end
