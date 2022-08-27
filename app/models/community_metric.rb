class CommunityMetric < BaseMetric
  def self.index_name
    "#{MetricsIndexPrefix}_community"
  end
end
