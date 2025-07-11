# frozen_string_literal: true

class ScorecardMetric < BaseMetric
  include BaseModelMetric

  def self.index_name
    "#{MetricsIndexPrefix}_scorecard"
  end

  def self.dimension
    'robustness'
  end

  def self.scope
    'software_artifact'
  end

  def self.ident
    'scorecard'
  end

  def self.text_ident
    'scorecard'
  end

  def self.fields_aliases
    {
      'scorecard_score' => 'score'
    }
  end
end
