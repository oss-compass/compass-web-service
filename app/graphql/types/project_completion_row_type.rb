# frozen_string_literal: true

module Types
  class ProjectCompletionRowType < Types::BaseObject
    field :label, String, description: 'metric model object identification'
    field :level, String, description: 'metric model object level (project or repo)'
    field :short_code, String, description: 'metric model object short code'
    field :status, String, description: 'metric task status (pending/progress/success/error/canceled/unsumbit)'
    field :collections, [String], description: 'second collections of this label'
    field :updated_at, GraphQL::Types::ISO8601DateTime, description: 'metric model last update time'
    field :type, String, description: 'type'
  end
end
