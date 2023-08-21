# frozen_string_literal: true

module Input
  class DatasetRowTypeInput < Types::BaseInputObject
    argument :label, String, required: true, description: 'metric model object identification'
    argument :level, String, required: true, description: 'metric model object level (project or repo)'
    argument :first_ident, String, required: false, description: 'first ident of the object'
    argument :second_ident, String, required: false, description: 'second ident of the object'
  end
end
