class BaseCollection < BaseIndex

  MaxItems = 2000

  def self.index_name
    "#{MetricsIndexPrefix}_collection"
  end

  def self.count_by(collection, level)
    base =
      self
        .must(match: { 'collection.keyword' => collection })
    base = base.must(match: { 'level.keyword' => level }) if level
    base.count
  end

  def self.list(collection, level, page, per)
    base =
      self
        .must(match: { 'collection.keyword' => collection })
        .page(page)
        .per(per)
    base = base.must(match: { 'level.keyword' => level }) if level
    base
      .execute
      .raw_response
  end

  def self.distinct_first_idents
    self
      .per(0)
      .page(0)
      .aggregate({ values: { terms: { field: 'first_collection.keyword', size: MaxItems } } })
      .execute
      .aggregations
      &.[]('values')
      &.[]('buckets')
      &.map{|item| item['key'] }
      &.sort
  end

  def self.distinct_second_idents(first_ident)
    self
      .per(0)
      .page(0)
      .where('first_collection.keyword' => first_ident)
      .aggregate({ values: { terms: { field: 'collection.keyword', size: MaxItems } } })
      .execute
      .aggregations
      &.[]('values')
      &.[]('buckets')
      &.map { |item| item['key'] }
      &.sort
  end

  def self.distinct_labels(first_ident, second_ident)
    self
      .per(0)
      .page(0)
      .where('first_collection.keyword' => first_ident)
      .where('collection.keyword' => second_ident)
      .aggregate({ values: { terms: { field: 'label.keyword', size: MaxItems } } })
      .execute
      .aggregations
      &.[]('values')
      &.[]('buckets')
      &.map{|item| item['key'] }
      &.sort
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

  def self.collections_of(label, limit: 10, field: 'collection')
    self
      .must(match: { 'label.keyword' => label })
      .custom(collapse: { field: "#{field}.keyword" })
      .per(limit)
      .source(field)
      .execute
      .raw_response
      .dig('hits', 'hits')
      .map { |row| row['_source'][field] }
      .compact
  rescue => ex
    Rails.logger.error("Failed to get collections of #{label}, #{ex.message}")
    []
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

  def self.hottest(collection, level, limit: 5)
    base =
      self
        .must(match: { 'collection.keyword' => collection })
        .sort(activity_delta: :desc)
        .page(1)
        .per(limit)
    base = base.must(match: { 'level.keyword' => level }) if level
    base
      .execute
      .raw_response
  end
end
