class CoreChurnMetric < BaseMetric
  include BaseModelMetric


  def self.index_name
    "#{MetricsIndexPrefix}_v2_core_churn"
  end


  def self.dimension
    'developer retention'
  end

  def self.scope
    'developer journey'
  end

  def self.ident
    'core_churn'
  end

  def self.text_ident
    'core_churn'
  end

  def self.main_score
    'score'
  end

end
