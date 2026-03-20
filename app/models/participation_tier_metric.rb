class ParticipationTierMetric < BaseMetric
  include BaseModelMetric

  
  def self.index_name
    "#{MetricsIndexPrefix}_v2_participation_tier"
  end



  def self.dimension
    'developer growth'
  end

  def self.scope
    'developer journey'
  end

  def self.ident
    'participation_tier'
  end

  def self.text_ident
    'participation_tier'
  end

  def self.main_score
    'score'
  end

end
