# frozen_string_literal: true

module Types
  module Lab
    class ModelMetricType < Types::BaseObject
      field :id, Integer
      field :metric_id, Integer
      field :name, String
      field :ident, String
      field :category, String
      field :from, String
      field :weight, Float
      field :threshold, Float
      field :default_weight, Float
      field :default_threshold, Float
      field :metric_type, Integer
    end
  end
end
