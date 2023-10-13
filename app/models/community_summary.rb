class CommunitySummary < BaseSummary
  def self.index_name
    "#{MetricsIndexPrefix}_community_summary"
  end

  def self.mapping
    {"properties"=>
     {"bug_issue_open_time_avg_mean"=>{"type"=>"float"},
      "bug_issue_open_time_avg_median"=>{"type"=>"float"},
      "bug_issue_open_time_mid_mean"=>{"type"=>"float"},
      "bug_issue_open_time_mid_median"=>{"type"=>"float"},
      "closed_prs_count_mean"=>{"type"=>"float"},
      "closed_prs_count_median"=>{"type"=>"float"},
      "code_review_count_mean"=>{"type"=>"float"},
      "code_review_count_median"=>{"type"=>"float"},
      "comment_frequency_mean"=>{"type"=>"float"},
      "comment_frequency_median"=>{"type"=>"float"},
      "community_support_score_mean"=>{"type"=>"float"},
      "community_support_score_median"=>{"type"=>"float"},
      "grimoire_creation_date"=>{"type"=>"date"},
      "issue_first_reponse_avg_mean"=>{"type"=>"float"},
      "issue_first_reponse_avg_median"=>{"type"=>"float"},
      "issue_first_reponse_mid_mean"=>{"type"=>"float"},
      "issue_first_reponse_mid_median"=>{"type"=>"float"},
      "issue_open_time_avg_mean"=>{"type"=>"float"},
      "issue_open_time_avg_median"=>{"type"=>"float"},
      "issue_open_time_mid_mean"=>{"type"=>"float"},
      "issue_open_time_mid_median"=>{"type"=>"float"},
      "metadata__enriched_on"=>{"type"=>"date"},
      "model_name"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
      "pr_first_response_time_avg_mean"=>{"type"=>"float"},
      "pr_first_response_time_avg_median"=>{"type"=>"float"},
      "pr_first_response_time_mid_mean"=>{"type"=>"float"},
      "pr_first_response_time_mid_median"=>{"type"=>"float"},
      "pr_open_time_avg_mean"=>{"type"=>"float"},
      "pr_open_time_avg_median"=>{"type"=>"float"},
      "pr_open_time_mid_mean"=>{"type"=>"float"},
      "pr_open_time_mid_median"=>{"type"=>"float"},
      "updated_issues_count_mean"=>{"type"=>"float"},
      "updated_issues_count_median"=>{"type"=>"float"},
      "uuid"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}}}}
  end
end
