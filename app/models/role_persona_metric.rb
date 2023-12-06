# frozen_string_literal: true

class RolePersonaMetric < BaseMetric
  def self.index_name
    "#{MetricsIndexPrefix}_role_persona"
  end

  def self.dimension
    'productivity'
  end

  def self.scope
    'contributor'
  end

  def self.ident
    'role_persona'
  end

  def self.text_ident
    'role_persona'
  end

  def self.fields_aliases
    {
      'role_persona_score' => 'score'
    }
  end
end
