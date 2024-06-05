# frozen_string_literal: true

module Types
  module Meta
    class CommunityDetailOverviewType < Types::BaseObject
      field :repo_count, Integer
      field :sig_count, Integer
      field :activity_score_avg, Float
      field :community_score_avg, Float
      field :commit_count, Integer
    end
  end
end
