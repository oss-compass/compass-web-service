# frozen_string_literal: true

module Types
  class TrendingType < Types::BaseObject
    field :name, String
    field :origin, String
    field :label, String
    field :level, String
    field :full_path, String
    field :activity_score, Float
    field :repos_count, Float
  end
end
