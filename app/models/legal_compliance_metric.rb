class LegalComplianceMetric < BaseMetric
  include BaseModelMetric

  
  def self.index_name
    "#{MetricsIndexPrefix}_v2_legal_compliance"
  end


  def self.dimension
    'source management'
  end

  def self.scope
    'supply chain security'
  end

  def self.ident
    'legal_compliance'
  end

  def self.text_ident
    'legal_compliance'
  end

  def self.main_score
    'score'
  end



end
