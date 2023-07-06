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
end
