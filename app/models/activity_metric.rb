class ActivityMetric < BaseMetric
  def self.index_name
    "#{MetricsIndexPrefix}_activity"
  end

  def self.dimension
    'robustness'
  end

  def self.scope
    'collaboration'
  end

  def self.ident
    'activity'
  end

  def self.text_ident
    'community_activity'
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

  def self.main_score
    'activity_score'
  end

  def self.build_snapshot(label)
    snaphost =
      self
        .must(match: { 'label.keyword': label })
        .range(:grimoire_creation_date, gte: Date.today.end_of_day - 1.month, lte: Date.today.end_of_day)
        .sort(grimoire_creation_date: :asc)
        .aggregate(
          {
            arise: {
              date_histogram: {
                field: :grimoire_creation_date,
                interval: "week",
              },
              aggs: {
                avg_activity: {
                  avg: {
                    field: "activity_score"
                  }
                },
                the_delta: {
                  derivative: {
                    buckets_path: "avg_activity"
                  }
                }
              }
            }
          }
        )
        .execute
        .aggregations
        &.[]('arise')
        &.[]('buckets')
        &.last

    level = label =~ URI::regexp ? 'repo' : 'community'

    if snaphost
      {
        label: label,
        level: level,
        activity_score: snaphost['avg_activity']['value'],
        activity_delta: snaphost['the_delta']['value'],
        updated_at: DateTime.parse(snaphost['key_as_string'])
      }
    else
      resp = query_label_one(label, level)
      snaphost = resp&.[]('hits')&.[]('hits').first
      if snaphost
        {
          label: label,
          level: level,
          activity_score: snaphost['_source']['activity_score'],
          activity_delta: 0,
          updated_at: DateTime.parse(snaphost['_source']['grimoire_creation_date'])
        }
      end
    end
  end

  def self.mapping
    {"properties"=>
     {"active_C1_issue_comments_contributor"=>{"type"=>"long"},
      "active_C1_issue_create_contributor"=>{"type"=>"long"},
      "active_C1_pr_comments_contributor"=>{"type"=>"long"},
      "active_C1_pr_create_contributor"=>{"type"=>"long"},
      "active_C2_contributor_count"=>{"type"=>"long"},
      "activity_score"=>{"type"=>"float"},
      "closed_issues_count"=>{"type"=>"long"},
      "code_review_count"=>{"type"=>"float"},
      "comment_frequency"=>{"type"=>"float"},
      "commit_frequency"=>{"type"=>"float"},
      "commit_frequency_bot"=>{"type"=>"float"},
      "commit_frequency_without_bot"=>{"type"=>"float"},
      "contributor_count"=>{"type"=>"long"},
      "contributor_count_bot"=>{"type"=>"long"},
      "contributor_count_without_bot"=>{"type"=>"long"},
      "created_since"=>{"type"=>"float"},
      "grimoire_creation_date"=>{"type"=>"date"},
      "label"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
      "level"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
      "metadata__enriched_on"=>{"type"=>"date"},
      "model_name"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
      "org_count"=>{"type"=>"long"},
      "recent_releases_count"=>{"type"=>"long"},
      "type"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
      "updated_issues_count"=>{"type"=>"long"},
      "updated_since"=>{"type"=>"float"},
      "uuid"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}}}}
  end
end
