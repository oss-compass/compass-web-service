# frozen_string_literal: true

module Types
  class TrendingType < Types::BaseObject
    field :name, String, description: 'repo or community name'
    field :origin, String, description: 'repo or community origin (gitee/github/combine)'
    field :label, String, description: 'repo or community label'
    field :level, String, description: 'repo or community level'
    field :short_code, String, description: 'repo or community short code'
    field :full_path, String, description: 'repo or community full_path, if community: equals name'
    field :activity_score, Float, description: 'repo or community latest activity avg'
    field :collections, [String], description: 'second collections of this label'
    field :repos_count, Float, description: 'repositories count'
  end
end
