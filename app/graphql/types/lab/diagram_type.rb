# frozen_string_literal: true

module Types
  module Lab
    class DiagramType < Types::BaseObject
      field :tab_ident, String, description: 'Tab ident for this diagram'
      field :type, String, description: 'Type of this diagram, default: `line`'
      field :dates, [GraphQL::Types::ISO8601DateTime, null: true], description: 'metric model creatiton time'
      field :values, [Float, null: true], description: 'y-axis values for this diagram'
    end
  end
end
