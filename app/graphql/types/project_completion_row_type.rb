# frozen_string_literal: true

module Types
  class ProjectCompletionRowType < Types::BaseObject
    field :label, String, description: 'metric model object identification'
    field :level, String, description: 'metric model object level (project or repo)'
  end
end
