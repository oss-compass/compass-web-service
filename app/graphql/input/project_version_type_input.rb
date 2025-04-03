# frozen_string_literal: true

module Input
  class ProjectVersionTypeInput < Types::BaseInputObject
    argument :label, String, required: true, description: 'metric model object identification'
    argument :version_number, String, required: false, description: 'version of the project'
  end
end
