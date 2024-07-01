# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareReportMetricComplianceDcoType < Types::BaseObject
      field :commit_count, Integer
      field :commit_dco_count, Integer
    end
  end
end
