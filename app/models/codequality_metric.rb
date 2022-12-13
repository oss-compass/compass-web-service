class CodequalityMetric < BaseMetric
  def self.index_name
    "#{MetricsIndexPrefix}_codequality"
  end

  def self.fields_aliases
    {
      'loc_frequency' => 'LOC_frequency',
      'active_c1_pr_create_contributor_count' => 'active_C1_pr_create_contributor',
      'active_c2_contributor_count' => 'active_C2_contributor_count',
      'active_c1_pr_comments_contributor_count' => 'active_C1_pr_comments_contributor',
    }
  end
end
