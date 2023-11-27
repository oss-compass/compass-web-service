class CodequalityMetric < BaseMetric
  def self.index_name
    "#{MetricsIndexPrefix}_codequality"
  end

  def self.mapping
    {"properties"=>
     {"LOC_frequency"=>{"type"=>"float"},
      "active_C1_pr_comments_contributor"=>{"type"=>"long"},
      "active_C1_pr_create_contributor"=>{"type"=>"long"},
      "active_C2_contributor_count"=>{"type"=>"long"},
      "code_merge_ratio"=>{"type"=>"float"},
      "code_quality_guarantee"=>{"type"=>"float"},
      "code_review_ratio"=>{"type"=>"float"},
      "commit_frequency"=>{"type"=>"float"},
      "commit_frequency_bot"=>{"type"=>"float"},
      "commit_frequency_inside"=>{"type"=>"float"},
      "commit_frequency_inside_bot"=>{"type"=>"long"},
      "commit_frequency_inside_without_bot"=>{"type"=>"long"},
      "commit_frequency_without_bot"=>{"type"=>"float"},
      "contributor_count"=>{"type"=>"long"},
      "contributor_count_bot"=>{"type"=>"long"},
      "contributor_count_without_bot"=>{"type"=>"long"},
      "git_pr_linked_ratio"=>{"type"=>"float"},
      "grimoire_creation_date"=>{"type"=>"date"},
      "is_maintained"=>{"type"=>"float"},
      "label"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
      "level"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
      "lines_added_frequency"=>{"type"=>"float"},
      "lines_removed_frequency"=>{"type"=>"float"},
      "metadata__enriched_on"=>{"type"=>"date"},
      "model_name"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
      "pr_commit_count"=>{"type"=>"long"},
      "pr_commit_linked_count"=>{"type"=>"long"},
      "pr_count"=>{"type"=>"long"},
      "pr_issue_linked_ratio"=>{"type"=>"float"},
      "pr_merged_count"=>{"type"=>"long"},
      "type"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
      "uuid"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}}}}
  end

  def self.ident
    'collab_dev_index'
  end

  def self.text_ident
    'collaboration_development_index'
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
