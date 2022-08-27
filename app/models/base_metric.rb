class BaseMetric
  MetricsIndexPrefix = ENV.fetch('METRICS_OUT_INDEX') { 'compass_metric' }
  include SearchFlip::Index

  def self.connection
    AuthSearchConn
  end
end
