class CodequalitySummary < BaseSummary
  def self.index_name
    "#{MetricsIndexPrefix}_codequality_summary"
  end

  def self.mapping
    {"properties"=>
     {"LOC_frequency_mean"=>{"type"=>"float"},
      "LOC_frequency_median"=>{"type"=>"float"},
      "active_C1_pr_comments_contributor_mean"=>{"type"=>"float"},
      "active_C1_pr_comments_contributor_median"=>{"type"=>"float"},
      "active_C1_pr_create_contributor_mean"=>{"type"=>"float"},
      "active_C1_pr_create_contributor_median"=>{"type"=>"float"},
      "active_C2_contributor_count_mean"=>{"type"=>"float"},
      "active_C2_contributor_count_median"=>{"type"=>"float"},
      "code_merge_ratio_mean"=>{"type"=>"float"},
      "code_merge_ratio_median"=>{"type"=>"float"},
      "code_quality_guarantee_mean"=>{"type"=>"float"},
      "code_quality_guarantee_median"=>{"type"=>"float"},
      "code_review_ratio_mean"=>{"type"=>"float"},
      "code_review_ratio_median"=>{"type"=>"float"},
      "commit_frequency_inside_mean"=>{"type"=>"float"},
      "commit_frequency_inside_median"=>{"type"=>"float"},
      "commit_frequency_mean"=>{"type"=>"float"},
      "commit_frequency_median"=>{"type"=>"float"},
      "contributor_count_mean"=>{"type"=>"float"},
      "contributor_count_median"=>{"type"=>"float"},
      "git_pr_linked_ratio_mean"=>{"type"=>"float"},
      "git_pr_linked_ratio_median"=>{"type"=>"float"},
      "grimoire_creation_date"=>{"type"=>"date"},
      "is_maintained_mean"=>{"type"=>"float"},
      "is_maintained_median"=>{"type"=>"float"},
      "lines_added_frequency_mean"=>{"type"=>"float"},
      "lines_added_frequency_median"=>{"type"=>"float"},
      "lines_removed_frequency_mean"=>{"type"=>"float"},
      "lines_removed_frequency_median"=>{"type"=>"float"},
      "metadata__enriched_on"=>{"type"=>"date"},
      "model_name"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
      "pr_commit_count_mean"=>{"type"=>"float"},
      "pr_commit_count_median"=>{"type"=>"float"},
      "pr_commit_linked_count_mean"=>{"type"=>"float"},
      "pr_commit_linked_count_median"=>{"type"=>"float"},
      "pr_count_mean"=>{"type"=>"float"},
      "pr_count_median"=>{"type"=>"float"},
      "pr_issue_linked_ratio_mean"=>{"type"=>"float"},
      "pr_issue_linked_ratio_median"=>{"type"=>"float"},
      "pr_merged_count_mean"=>{"type"=>"float"},
      "pr_merged_count_median"=>{"type"=>"float"},
      "uuid"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}}}}
  end
end
