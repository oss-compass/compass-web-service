class DeveloperBaseMetric < BaseMetric
  include BaseModelMetric

  
  def self.index_name
    "#{MetricsIndexPrefix}_v2_developer_base"

  end



  # def self.main_score
  #   'activity_score'
  # end


  # def self.mapping
  #   {"properties"=>
  #    {"active_C1_issue_comments_contributor"=>{"type"=>"long"},
  #     "active_C1_issue_create_contributor"=>{"type"=>"long"},
  #     "active_C1_pr_comments_contributor"=>{"type"=>"long"},
  #     "active_C1_pr_create_contributor"=>{"type"=>"long"},
  #     "active_C2_contributor_count"=>{"type"=>"long"},
  #     "activity_score"=>{"type"=>"float"},
  #     "closed_issues_count"=>{"type"=>"long"},
  #     "code_review_count"=>{"type"=>"float"},
  #     "comment_frequency"=>{"type"=>"float"},
  #     "commit_frequency"=>{"type"=>"float"},
  #     "commit_frequency_bot"=>{"type"=>"float"},
  #     "commit_frequency_without_bot"=>{"type"=>"float"},
  #     "contributor_count"=>{"type"=>"long"},
  #     "contributor_count_bot"=>{"type"=>"long"},
  #     "contributor_count_without_bot"=>{"type"=>"long"},
  #     "created_since"=>{"type"=>"float"},
  #     "grimoire_creation_date"=>{"type"=>"date"},
  #     "label"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
  #     "level"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
  #     "metadata__enriched_on"=>{"type"=>"date"},
  #     "model_name"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
  #     "org_count"=>{"type"=>"long"},
  #     "recent_releases_count"=>{"type"=>"long"},
  #     "type"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
  #     "updated_issues_count"=>{"type"=>"long"},
  #     "updated_since"=>{"type"=>"float"},
  #     "uuid"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}}}}
  # end
end
