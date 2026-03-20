class SecurityManagementMetric < BaseMetric
  include BaseModelMetric

  
  def self.index_name
    "#{MetricsIndexPrefix}_v2_security_management"
  end


  def self.dimension
    'source management'
  end

  def self.scope
    'supply chain security'
  end

  def self.ident
    'security_management'
  end

  def self.text_ident
    'security_management'
  end

  def self.main_score
    'score'
  end



end
