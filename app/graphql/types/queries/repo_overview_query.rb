# frozen_string_literal: true

module Types
  module Queries
    class RepoOverviewQuery < BaseQuery

      type [Types::Metric::CategoryOverviewType], null: false
      description 'Get overview data of a repo'
      argument :label, String, required: true, description: 'repo label'

      OVERVIEW_CACHE_KEY = 'compass-repo-overview'

      def resolve(label: nil)
        [{category: "Test", items: [{ident: "most string", result: { value: "test" } }, {ident: "most value", result: {value: 33.0}}]}]
      end
    end
  end
end
