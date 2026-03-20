class DeveloperPromotionMetric < BaseMetric
  include BaseModelMetric

  
  def self.index_name
    "#{MetricsIndexPrefix}_v2_developer_promotion"
  end



  def self.dimension
    'developer growth'
  end

  def self.scope
    'developer journey'
  end

  def self.ident
    'developer_promotion'
  end

  def self.text_ident
    'developer_promotion'
  end

  def self.main_score
    'score'
  end

end
