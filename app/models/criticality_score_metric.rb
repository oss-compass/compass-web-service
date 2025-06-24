# frozen_string_literal: true

class CriticalityScoreMetric < BaseMetric
  include BaseModelMetric

  def self.index_name
    "#{MetricsIndexPrefix}_criticality_score"
  end

  def self.dimension
    'robustness'
  end

  def self.scope
    'software_artifact'
  end

  def self.ident
    'criticality_score'
  end

  def self.text_ident
    'criticality_score'
  end

  def self.fields_aliases
    {
      'criticality_score_score' => 'score'
    }
  end
end
