class BaseMetric
  MetricsIndexPrefix = ENV.fetch('METRICS_OUT_INDEX') { 'compass_metric' }
  include SearchFlip::Index

  def self.connection
    AuthSearchConn
  end

  def self.query_repo_by_date(repo_url, begin_date, end_date, page: 1, per: 30)
    self
      .must(match_phrase: { label: repo_url })
      .page(page)
      .per(per)
      .range(:grimoire_creation_date, gte: begin_date, lte: end_date)
      .execute
      .raw_response
  end

  def self.aggs_repo_by_date(repo_url, begin_date, end_date, aggs)
    self
      .must(match_phrase: { label: repo_url })
      .page(1)
      .per(1)
      .range(:grimoire_creation_date, gte: begin_date, lte: end_date)
      .aggregate(aggs)
      .execute
      .raw_response
  end

  def self.fuzzy_search(keyword, field, collapse, fields: [], filters: {}, limit: 5)
    base =
      self
        .search(keyword, default_field: field)
        .per(limit)
        .custom(collapse: {
                  field: collapse ,
                  inner_hits: { name: "by_level", collapse: { field: "level.keyword" } } })

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

  def self.exist_one?(field, value, keyword: true)
    self.must(match: { "#{field}#{keyword ? '.keyword' : ''}" => value }).total_entries > 0
  end
end
