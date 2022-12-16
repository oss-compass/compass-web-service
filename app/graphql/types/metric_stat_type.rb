# frozen_string_literal: true

module Types
  class MetricStatType < Types::BaseObject
    field :mean, Float, description: 'arithmetic mean'
    field :median, Float, description: '50 percentile'
  end
end
