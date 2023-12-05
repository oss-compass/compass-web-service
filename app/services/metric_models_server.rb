# frozen_string_literal: true

class MetricModelsServer

  def initialize(label: ,level: 'repo', repo_type: nil, opts: {})
    @label = label
    @level = level
    @repo_type = repo_type || level == 'community' ? 'software-artifact' : nil
    @opts = opts
  end

  def overview
    [
      ActivityMetric,
      CodequalityMetric,
      CommunityMetric,
      GroupActivityMetric,
      DomainPersonaMetric,
      RolePersonaMetric,
      MilestonePersonaMetric
    ].map do |metric|
      build_template(metric)
    end
      .compact
  end

  private
  def build_template(metric)
    result = metric.query_label_one(@label, @level, type: @repo_type, force: @opts[:force_refresh])
    hits = result&.[]('hits')&.[]('hits')
    hit = hits.present? ? hits.first['_source'] : nil
    basic =
      {
        dimension: metric.dimension,
        ident: metric.ident,
        scope: metric.scope,
        type: @repo_type,
        label: @label,
        level: @level,
        main_score: 0.0,
        transformed_score: 0.0,
        grimoire_creation_date: nil,
        updated_at: nil,
        short_code: ShortenedLabel.convert(@label, @level)
      }
    if hit.present?
      basic[:main_score] = hit[metric.main_score]
      basic[:transformed_score] = metric.scaled_value(nil, target_value: basic[:main_score])
      basic[:grimoire_creation_date] =
        DateTime.parse(hit&.[]('grimoire_creation_date')).strftime rescue hit&.[]('grimoire_creation_date')
      basic[:updated_at] =
        DateTime.parse(hit&.[]('metadata__enriched_on')).strftime rescue hit&.[]('metadata__enriched_on')
      basic
    end
  end
end
