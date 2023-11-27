# frozen_string_literal: true

module Types
  module Queries
    class MetricModelsOverviewQuery < BaseQuery
      type [Types::Metric::ModelType], null: false
      description 'Metric models graph'
      argument :label, String, required: true, description: 'repo or community label'
      argument :level, String, required: false, description: 'repo or project', default_value: 'repo'
      argument :repo_type, String, required: false, description: 'repo type, for repo level default: null and community level default: software-artifact'

      def resolve(label:, level: 'repo', repo_type: nil)
        MetricModelsServer.new(label: label, level: level, repo_type: repo_type).overview
      end
    end
  end
end
