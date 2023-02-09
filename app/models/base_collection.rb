class BaseCollection < BaseIndex
  def self.index_name
    "#{MetricsIndexPrefix}_collection"
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
