# frozen_string_literal: true

class MilestonePersonaMetric < BaseMetric
  include BaseModelMetric

  def self.index_name
    "#{MetricsIndexPrefix}_milestone_persona"
  end

  def self.dimension
    'productivity'
  end

  def self.scope
    'contributor'
  end

  def self.ident
    'milestone_persona'
  end

  def self.text_ident
    'milestone_persona'
  end

  def self.fields_aliases
    {
      'milestone_persona_score' => 'score'
    }
  end
end
