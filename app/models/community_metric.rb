class CommunityMetric < BaseMetric
  def self.index_name
    "#{MetricsIndexPrefix}_community"
  end

  def self.main_score
    'community_support_score'
  end
end
