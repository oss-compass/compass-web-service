class ActivityMetric < BaseMetric
  def self.index_name
    "#{MetricsIndexPrefix}_activity"
  end
end
