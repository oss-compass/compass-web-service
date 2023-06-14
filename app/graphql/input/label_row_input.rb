# frozen_string_literal: true

module Input
  class LabelRowInput < Types::BaseInputObject
    argument :label, String, description: 'metric model object identification'
    argument :level, String, description: 'metric model object level (project or repo)'
  end
end
