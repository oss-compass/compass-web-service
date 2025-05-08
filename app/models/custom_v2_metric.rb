class CustomV2Metric < BaseMetric
  include BaseModelMetric

  def self.index_name
    "#{MetricsIndexPrefix}_custom_v2"
  end
end
