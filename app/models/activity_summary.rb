class ActivitySummary < BaseSummary
  def self.index_name
    "#{MetricsIndexPrefix}_activity_summary"
  end
end
