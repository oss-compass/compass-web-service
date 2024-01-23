class BaseIndex
  MetricsIndexPrefix = ENV.fetch('METRICS_OUT_INDEX') { 'compass_metric' }
  CacheTTL = 15.minutes
  MiddleCacheTTL = 2.hours
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

  def self.fuzzy_search(keyword, field, collapse, fields: [], filters: {}, limit: 5)
    base =
      self
        .search(keyword, default_field: field)
        .per(limit)
    filters.map do |k, value|
      if value.present?
        base = base.where(k => value)
      end
    end

    base
      .source(fields)
      .execute
      .raw_response
  end

  def self.prefix_search(keyword, field, collapse, fields: [], filters: {}, limit: 5)
    base =
      self
        .must(prefix: { field => keyword })
        .per(limit)
    filters.map do |k, value|
      if value.present?
        base = base.where(k => value)
      end
    end

    base
      .source(fields)
      .execute
      .raw_response
  end

  def self.fields_aliases
    {}
  end
end
