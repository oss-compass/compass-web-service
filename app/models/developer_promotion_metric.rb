class DeveloperPromotionMetric < BaseMetric
  include BaseModelMetric

  
  def self.index_name
    "#{MetricsIndexPrefix}_v2_developer_promotion"
  end



  # def self.main_score
  #   'activity_score'
  # end

end
