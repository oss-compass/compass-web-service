class GroupActivityMetric < BaseMetric
  def self.index_name
    "#{MetricsIndexPrefix}_group_activity"
  end

  def self.text_ident
    'organization_activity'
  end

  def self.main_score
    'organizations_activity'
  end

  def self.query_label_one(label, level)
    Rails.cache.fetch(
      "#{self.name}-#{__method__}-#{label}-#{level}",
      expires_in: CacheTTL
    ) do
      self
        .must(match: { 'label.keyword': label })
        .where(is_org: true)
        .where(level: level)
        .page(1)
        .per(1)
        .sort(grimoire_creation_date: :desc)
        .execute
        .raw_response
    end
  end

  def self.find_one(field, value, keyword: true)
    self.must(match: { "#{field}#{keyword ? '.keyword' : ''}" => value })
      .where(is_org: true)
      .page(1)
      .per(1)
      .sort(grimoire_creation_date: :desc)
      .execute
      .raw_response
      .dig('hits', 'hits', 0, '_source')
  end

  def self.aggs_repo_by_date(repo_url, begin_date, end_date, aggs, type: nil)
    Rails.cache.fetch(
      "#{self.name}:#{__method__}:#{repo_url}:#{begin_date}:#{end_date}",
      expires_in: CacheTTL
    ) do
      self
        .must(match: { 'label.keyword': repo_url })
        .where(is_org: true)
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
end
