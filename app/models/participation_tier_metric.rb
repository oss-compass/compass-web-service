class ParticipationTierMetric < BaseMetric
  include BaseModelMetric

  
  def self.index_name
    "#{MetricsIndexPrefix}_v2_participation_tier"
  end



  # def self.main_score
  #   'activity_score'
  # end

end
