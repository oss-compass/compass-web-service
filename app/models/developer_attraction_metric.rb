class DeveloperAttractionMetric < BaseMetric
  include BaseModelMetric

  
  def self.index_name
    "#{MetricsIndexPrefix}_v2_developer_attraction"
  end


  def self.dimension
    'developer attraction'
  end

  def self.scope
    'developer journey'
  end

  def self.ident
    'developer_attraction'
  end

  def self.text_ident
    'developer_attraction'
  end

  def self.main_score
    'score'
  end

end
