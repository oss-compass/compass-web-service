# frozen_string_literal: true

class StarterProjectHealthMetric < BaseMetric
  def self.index_name
    "#{MetricsIndexPrefix}_starter_project_health"
  end
end
