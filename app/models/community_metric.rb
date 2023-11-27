class CommunityMetric < BaseMetric
  def self.index_name
    "#{MetricsIndexPrefix}_community"
  end

  def self.mapping
    {"properties"=>
     {"bug_issue_open_time_avg"=>{"type"=>"float"},
      "bug_issue_open_time_mid"=>{"type"=>"float"},
      "closed_prs_count"=>{"type"=>"long"},
      "code_review_count"=>{"type"=>"float"},
      "comment_frequency"=>{"type"=>"float"},
      "community_support_score"=>{"type"=>"float"},
      "grimoire_creation_date"=>{"type"=>"date"},
      "issue_first_reponse_avg"=>{"type"=>"float"},
      "issue_first_reponse_mid"=>{"type"=>"float"},
      "issue_open_time_avg"=>{"type"=>"float"},
      "issue_open_time_mid"=>{"type"=>"float"},
      "label"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
      "level"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
      "metadata__enriched_on"=>{"type"=>"date"},
      "model_name"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
      "pr_first_response_time_avg"=>{"type"=>"float"},
      "pr_first_response_time_mid"=>{"type"=>"float"},
      "pr_open_time_avg"=>{"type"=>"float"},
      "pr_open_time_mid"=>{"type"=>"float"},
      "type"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
      "updated_issues_count"=>{"type"=>"long"},
      "uuid"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}}}}
  end

  def self.ident
    'community'
  end

  def self.text_ident
    'community_service_and_support'
  end

  def self.main_score
    'community_support_score'
  end
end
