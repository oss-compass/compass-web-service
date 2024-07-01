# frozen_string_literal: true

module Types
  module Tpc
    class TpcSoftwareReportMetricEcologySoftwareQualityType < Types::BaseObject
      field :duplication_score, Integer
      field :duplication_ratio, Float
      field :coverage_score, Integer
      field :coverage_ratio, Float
    end
  end
end
