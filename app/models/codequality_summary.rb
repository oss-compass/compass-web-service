class CodequalitySummary < BaseSummary
  def self.index_name
    "#{MetricsIndexPrefix}_codequality_summary"
  end
end
