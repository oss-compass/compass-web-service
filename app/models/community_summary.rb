class CommunitySummary < BaseSummary
  def self.index_name
    "#{MetricsIndexPrefix}_community_summary"
  end
end
