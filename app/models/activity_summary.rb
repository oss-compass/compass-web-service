class ActivitySummary < BaseSummary
  def self.index_name
    "#{MetricsIndexPrefix}_activity_summary"
  end

  def self.mapping
    {"properties"=>
     {"active_C1_issue_comments_contributor_mean"=>{"type"=>"float"},
      "active_C1_issue_comments_contributor_median"=>{"type"=>"float"},
      "active_C1_issue_create_contributor_mean"=>{"type"=>"float"},
      "active_C1_issue_create_contributor_median"=>{"type"=>"float"},
      "active_C1_pr_comments_contributor_mean"=>{"type"=>"float"},
      "active_C1_pr_comments_contributor_median"=>{"type"=>"float"},
      "active_C1_pr_create_contributor_mean"=>{"type"=>"float"},
      "active_C1_pr_create_contributor_median"=>{"type"=>"float"},
      "active_C2_contributor_count_mean"=>{"type"=>"float"},
      "active_C2_contributor_count_median"=>{"type"=>"float"},
      "activity_score_mean"=>{"type"=>"float"},
      "activity_score_median"=>{"type"=>"float"},
      "closed_issues_count_mean"=>{"type"=>"float"},
      "closed_issues_count_median"=>{"type"=>"float"},
      "code_review_count_mean"=>{"type"=>"float"},
      "code_review_count_median"=>{"type"=>"float"},
      "comment_frequency_mean"=>{"type"=>"float"},
      "comment_frequency_median"=>{"type"=>"float"},
      "commit_frequency_mean"=>{"type"=>"float"},
      "commit_frequency_median"=>{"type"=>"float"},
      "contributor_count_mean"=>{"type"=>"float"},
      "contributor_count_median"=>{"type"=>"float"},
      "created_since_mean"=>{"type"=>"float"},
      "created_since_median"=>{"type"=>"float"},
      "grimoire_creation_date"=>{"type"=>"date"},
      "metadata__enriched_on"=>{"type"=>"date"},
      "model_name"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
      "org_count_mean"=>{"type"=>"float"},
      "org_count_median"=>{"type"=>"float"},
      "recent_releases_count_mean"=>{"type"=>"float"},
      "recent_releases_count_median"=>{"type"=>"float"},
      "updated_issues_count_mean"=>{"type"=>"float"},
      "updated_issues_count_median"=>{"type"=>"float"},
      "updated_since_mean"=>{"type"=>"float"},
      "updated_since_median"=>{"type"=>"float"},
      "uuid"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}}}}
  end
end
