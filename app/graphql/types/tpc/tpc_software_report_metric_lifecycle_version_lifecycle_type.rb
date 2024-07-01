# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareReportMetricLifecycleVersionLifecycleType < Types::BaseObject
      field :archived, Boolean
      field :latest_version_name, String
      field :latest_version_created_at, GraphQL::Types::ISO8601DateTime
    end
  end
end
