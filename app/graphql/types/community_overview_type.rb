# frozen_string_literal: true

module Types
  class CommunityOverviewType < Types::BaseObject
    field :community_url, String
    field :projects_count, Integer
    field :trends, [Types::RepoType]
  end
end
