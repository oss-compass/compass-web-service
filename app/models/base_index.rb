class BaseIndex
  MetricsIndexPrefix = ENV.fetch('METRICS_OUT_INDEX') { 'compass_metric' }
  CacheTTL = 2.minutes
  LongCacheTTL = 1.day
  include SearchFlip::Index

  def self.connection
    AuthSearchConn
  end

  def self.model
    OpenStruct
  end

  def self.serialize(struct)
    struct.as_json['table']
  end

  def self.fields_aliases
    {}
  end
end
