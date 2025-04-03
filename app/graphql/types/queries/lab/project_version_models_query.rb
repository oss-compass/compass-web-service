# frozen_string_literal: true

module Types
  module Queries
    module Lab
      class ProjectVersionModelsQuery < BaseQuery

        type Types::Financial::ProjectVersionModelType, null: true
        description 'Get project detail'
        argument :label, String, required: true, description: 'project url'
        argument :version_number, String, required: true, description: 'project url'

        def resolve(label: nil, version_number: nil)
          limit = 10
          resp = CustomV1Metric.query_repo_by_version(label, version_number, page: 1, per: limit)
          hits = resp&.fetch('hits', {})&.fetch('hits', [])
          items = hits.map { |hit| hit['_source'] }

          { items: items }
        end
      end
    end
  end
end

