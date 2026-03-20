class DevelopmentDocumentQualityMetric < BaseMetric
  include BaseModelMetric

  
  def self.index_name
    "#{MetricsIndexPrefix}_v2_development_document_quality"
  end


  def self.dimension
    'dev and build'
  end

  def self.scope
    'supply chain security'
  end

  def self.ident
    'development_document_quality'
  end

  def self.text_ident
    'development_document_quality'
  end

  def self.main_score
    'score'
  end



end
