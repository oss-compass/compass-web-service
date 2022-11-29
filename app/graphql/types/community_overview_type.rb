# frozen_string_literal: true

module Types
  class CommunityOverviewType < Types::BaseObject
    field :projects_count, Integer
    field :trends, [Types::RepoType]
  end
end
