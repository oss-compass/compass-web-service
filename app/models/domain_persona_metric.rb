# frozen_string_literal: true

class DomainPersonaMetric < BaseMetric
  def self.index_name
    "#{MetricsIndexPrefix}_domain_persona"
  end

  def self.dimension
    'productivity'
  end

  def self.scope
    'contributor'
  end

  def self.ident
    'domain_persona'
  end

  def self.text_ident
    'domain_persona'
  end
end
