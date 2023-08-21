# frozen_string_literal: true

module Types
  module Lab
    class PanelType < Types::BaseObject
      field :metric, ModelMetricType, description: 'panel corresponding metric data'
      field :diagrams, [DiagramType], description: 'specific fields and chart types for metric data'
    end
  end
end
