# frozen_string_literal: true

module Types
  class ProjectCompletionRowType < Types::BaseObject
    field :label, String, description: 'metric model object identification'
    field :level, String, description: 'metric model object level (project or repo)'
    field :status, String, description: 'metric task status (pending/progress/success/error/canceled/unsumbit)'
  end
end
