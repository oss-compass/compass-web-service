class BaseMetric < BaseIndex
  def self.query_repo_by_date(repo_url, begin_date, end_date, page: 1, per: 60)
    Rails.cache.fetch(
      "#{self.name}-#{__method__}-#{repo_url}-#{begin_date}-#{end_date}-#{page}-#{per}",
      expires_in: CacheTTL
    ) do
      self
        .must(match: { 'label.keyword': repo_url })
        .page(page)
        .per(per)
        .range(:grimoire_creation_date, gte: begin_date, lte: end_date)
        .sort(grimoire_creation_date: :asc)
        .execute
        .raw_response
    end
  end

  def self.query_label_one(label, level)
    Rails.cache.fetch(
      "#{self.name}-#{__method__}-#{label}-#{level}",
      expires_in: CacheTTL
    ) do
      self
        .must(match: { 'label.keyword': label })
        .where(level: level)
        .page(1)
        .per(1)
        .sort(grimoire_creation_date: :desc)
        .execute
        .raw_response
    end
  end

  def self.recent(limit)
    Rails.cache.fetch(
      "#{self.name}-#{__method__}-#{limit}",
      expires_in: CacheTTL
    ) do
      self
        .page(1)
        .per(limit)
        .custom(collapse: { field: 'label.keyword' })
        .sort(metadata__enriched_on: :desc)
        .execute
        .raw_response
    end
  end

  def self.aggs_repo_by_date(repo_url, begin_date, end_date, aggs)
    Rails.cache.fetch(
      "#{self.name}-#{__method__}-#{repo_url}-#{begin_date}-#{end_date}",
      expires_in: CacheTTL
    ) do
      self
        .must(match: { 'label.keyword': repo_url })
        .page(1)
        .per(1)
        .range(:grimoire_creation_date, gte: begin_date, lte: end_date)
        .sort(grimoire_creation_date: :asc)
        .aggregate(aggs)
        .execute
        .raw_response
    end
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
      .custom(collapse: {
                field: collapse ,
                inner_hits: { name: "by_level", collapse: { field: "level.keyword" } } })
      .source(fields)
      .execute
      .raw_response
  end

  def self.exist_one?(field, value, keyword: true)
    self.must(match: { "#{field}#{keyword ? '.keyword' : ''}" => value }).total_entries > 0
  end
end
