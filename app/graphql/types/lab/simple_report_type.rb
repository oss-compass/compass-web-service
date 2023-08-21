# frozen_string_literal: true

module Types
  module Lab
    class SimpleReportType < Types::BaseObject
      field :label, String, description: 'metric model object identification'
      field :level, String, description: 'metric model object level'
      field :short_code, String, description: 'metric model object short code'
      field :type, String, description: 'metric scores for repositories type, only for community (software-artifact/governance)'
      field :main_score, DiagramType, description: 'main score diagram for metric model'
    end
  end
end
