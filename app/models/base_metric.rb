class BaseMetric < BaseIndex
  def self.query_repo_by_date(repo_url, begin_date, end_date, page: 1, per: 60, type: nil)
    Rails.cache.fetch(
      "#{self.name}:#{__method__}:#{repo_url}:#{begin_date}:#{end_date}:#{page}:#{per}:#{type}",
      expires_in: CacheTTL
    ) do
      self
        .must(match: { 'label.keyword': repo_url })
        .where('type.keyword': type)
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

  def self.aggs_repo_by_date(repo_url, begin_date, end_date, aggs, type: nil)
    Rails.cache.fetch(
      "#{self.name}:#{__method__}:#{repo_url}:#{begin_date}:#{end_date}:#{type}",
      expires_in: CacheTTL
    ) do
      self
        .must(match: { 'label.keyword': repo_url })
        .where('type.keyword': type)
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

  def self.find_one(field, value, keyword: true)
    self.must(match: { "#{field}#{keyword ? '.keyword' : ''}" => value })
      .page(1)
      .per(1)
      .sort(grimoire_creation_date: :desc)
      .execute
      .raw_response
      .dig('hits', 'hits', 0, '_source')
  end

  def self.main_score
    'score'
  end

  def self.text_ident
    'text_ident'
  end

  def self.i18n_name
    I18n.t("metrics_models.#{self.text_ident}.title")
  end

  def self.scaled_value(source, target_value: nil)
    scale = -> (value, from_min, from_max, to_min, to_max) {
      (to_min + ((value - from_min) / (from_max - from_min)) * (to_max - to_min)).truncate
    }
    value = (target_value || source&.dig(self.main_score)).to_f
    case value
    when 0..0.1
      scale.(value, 0, 0.1, 0, 60)
    when 0.1..0.2
      scale.(value, 0.1, 0.2, 60, 65)
    when 0.2..0.3
      scale.(value, 0.2, 0.3, 65, 75)
    when 0.3..0.5
      scale.(value, 0.3, 0.5, 75, 80)
    when 0.5..0.6
      scale.(value, 0.5, 0.6, 80, 85)
    when 0.6..0.7
      scale.(value, 0.6, 0.7, 85, 90)
    when 0.7..0.8
      scale.(value, 0.7, 0.8, 90, 95)
    when 0.8..1
      scale.(value, 0.8, 1, 95, 100)
    else
      -1
    end
  end
end
