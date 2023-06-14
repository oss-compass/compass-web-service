# frozen_string_literal: true

module Types
  class LabelRowType < Types::BaseObject
    field :label, String, description: 'metric model object identification'
    field :level, String, description: 'metric model object level (project or repo)'
    field :short_code, String, description: 'metric model object short code'
  end
end
