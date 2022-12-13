class ActivityMetric < BaseMetric
  def self.index_name
    "#{MetricsIndexPrefix}_activity"
  end

  def self.fields_aliases
    {
      'active_c1_pr_create_contributor_count' => 'active_C1_pr_create_contributor',
      'active_c2_contributor_count' => 'active_C2_contributor_count',
      'active_c1_pr_comments_contributor_count' => 'active_C1_pr_comments_contributor',
      'active_c1_issue_create_contributor_count' => 'active_C1_issue_create_contributor',
      'active_c1_issue_comments_contributor_count' => 'active_C1_issue_comments_contributor'
    }
  end
end
