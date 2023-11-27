# frozen_string_literal: true

class MetricModelsServer

  def initialize(label: ,level: 'repo', repo_type: nil, opts: {})
    @label = label
    @level = level
    @repo_type = repo_type
    @opts = opts
  end

  def overview
    {
      productivity: productivity,
      robustness: robustness,
      niche_creation: niche_creation,
      type: @repo_type,
      label: @label,
      level: @level,
      upladed_at: @opts[:upladed_at] || updated_at || Time.now
    }
  end

  def updated_at
    Time.now
  end

  def productivity
    [
      build_template(CodequalityMetric),
      build_template(CommunityMetric),
    ].compact
  end

  def robustness
    [build_template(ActivityMetric)]
  end

  def niche_creation
    [build_template(GroupActivityMetric)]
  end

  private
  def build_template(metric)
    result = metric.query_label_one(@label, @level, type: @repo_type)
    hits = result&.[]('hits')&.[]('hits')
    hit = hits.present? ? hits.first['_source'] : nil
    if hit.present?
      main_score = hit[metric.main_score]
      transformed_score = metric.scaled_value(nil, target_value: main_score)

      grimoire_creation_date = DateTime.parse(hit&.[]('grimoire_creation_date')).strftime rescue hit&.[]('grimoire_creation_date')
      {
        ident: metric.ident,
        type: @repo_type,
        label: @label,
        level: @level,
        main_score: main_score,
        transformed_score: transformed_score,
        grimoire_creation_date: grimoire_creation_date
      }
    end
  end
end
