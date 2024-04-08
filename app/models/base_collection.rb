class BaseCollection < BaseIndex

  MaxItems = 2000

  def self.index_name
    "#{MetricsIndexPrefix}_collection"
  end

  def self.mapping
    {"properties"=>
     {"activity_delta"=>{"type"=>"float"},
      "activity_score"=>{"type"=>"float"},
      "collection"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
      "first_collection"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
      "id"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
      "label"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
      "level"=>{"type"=>"text", "fields"=>{"keyword"=>{"type"=>"keyword", "ignore_above"=>256}}},
      "updated_at"=>{"type"=>"date"}}}
  end

  def self.count_by(collection, level)
    base =
      self
        .must(match: { 'collection.keyword' => collection })
    base = base.must(match: { 'level.keyword' => level }) if level
    base..total_entries
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

  def self.collections_of(label, limit: 10, field: 'collection', level: 'repo')
    return [] unless level == 'repo'
    Rails.cache.fetch("#{self.name}:#{__method__}:#{label}:#{limit}:#{field}:#{level}", expires_in: MiddleCacheTTL) do
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
    end
  rescue => ex
    Rails.logger.error("Failed to get collections of #{label}, #{ex.message}")
    []
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
