class CodeReviewQualityMetric < BaseMetric
  include BaseModelMetric

  
  def self.index_name
    "#{MetricsIndexPrefix}_v2_code_review_quality"
  end


  def self.dimension
    'dev and build'
  end

  def self.scope
    'supply chain security'
  end

  def self.ident
    'code_review_quality'
  end

  def self.text_ident
    'code_review_quality'
  end

  def self.main_score
    'score'
  end



end
