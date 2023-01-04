# frozen_string_literal: true

module Types
  module Queries
    class BetaMetricsIndexQuery < BaseQuery
      include Pagy::Backend
      type [BetaMetricType], null: false
      description 'return beta metrics list'
      argument :status, String, required: false, description: 'filter by status'
      argument :metric, String, required: false, description: 'filter by metric'
      argument :dimensionality, String, required: false, description: 'filter by dimensionality'
      argument :per, Integer, required: false, description: 'per number'
      argument :page, Integer, required: false, description: 'page number'
      def resolve(status: nil, metric: nil, dimensionality: nil, per: 5, page: 1)
        beta_metrics = BetaMetric
        beta_metrics = beta_metrics.where(status: status) if status
        beta_metrics = beta_metrics.where(metric: metric) if metric
        beta_metrics = beta_metrics.where(metric: dimensionality) if dimensionality
        _, records = pagy(beta_metrics, { page: page, items: per })
        records
      end
    end
  end
end
