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

  def self.calc_fields
    {
      'code_merged_count' => ['code_merge_ratio', 'pr_count'],
      'code_reviewed_count' => ['code_review_ratio', 'pr_count'],
      'pr_issue_linked_count' => ['pr_issue_linked_ratio', 'pr_count']
    }
  end

  def self.main_score
    'code_quality_guarantee'
  end
end
