class CoreRetentionMetric < BaseMetric
  include BaseModelMetric

  
  def self.index_name
    "#{MetricsIndexPrefix}_v2_core_retention"
  end



  # def self.main_score
  #   'activity_score'
  # end

end
