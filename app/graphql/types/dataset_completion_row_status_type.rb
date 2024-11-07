# frozen_string_literal: true

module Types
  class DatasetCompletionRowStatusType < Types::BaseObject
    field :label, String, description: 'metric model object identification'
    field :level, String, description: 'metric model object level (project or repo)'
    field :short_code, String, description: 'short code of metric model object label'
    field :first_ident, String, description: 'first ident of the object'
    field :second_ident, String, description: 'second ident of the object'
    field :trigger_status, String,description: 'trigger status'
    field :trigger_updated_at, GraphQL::Types::ISO8601DateTime, description: 'trigger updated at'
    field :logo_url, String, description: 'repo or community logo_url'
  end
end
