class CustomV1Metric < BaseMetric
  def self.index_name
    "#{MetricsIndexPrefix}_custom_v1"
  end

  def self.exist_model_and_version(model_id, version_id)
    self
      .where(model_id: model_id)
      .where(version_id: version_id)
      .total_entries > 0
  end

  def self.query_by_model_and_version(model_id, version_id, begin_date, end_date, limit: 30)
    Rails.cache.fetch(
      "#{self.name}:#{__method__}:#{model_id}:#{version_id}:#{begin_date}:#{end_date}:#{limit}",
      expires_in: CacheTTL
    ) do
      self
        .per(0)
        .where(model_id: model_id)
        .where(version_id: version_id)
        .range(:grimoire_creation_date, gte: begin_date, lte: end_date)
        .aggregate(
          {
            reports: {
              terms: { field: 'label.keyword' },
              aggs: {
                docs: {
                  top_hits: {
                    size: limit,
                    sort: [
                      {
                        grimoire_creation_date: {
                          order: 'asc'
                        }
                      }
                    ]
                  }
                }
              }
            }
          }
        )
        .aggregations
    end
  end


  def self.query_repo_by_date(model_id, version_id, label, begin_date, end_date, page: 1, per: 60)
    Rails.cache.fetch(
      "#{self.name}:#{__method__}:#{model_id}:#{version_id}:#{label}-#{begin_date}-#{end_date}-#{page}-#{per}",
      expires_in: CacheTTL
    ) do
      self
        .where(model_id: model_id)
        .where(version_id: version_id)
        .must(match: { 'label.keyword': label })
        .page(page)
        .per(per)
        .range(:grimoire_creation_date, gte: begin_date, lte: end_date)
        .sort(grimoire_creation_date: :asc)
        .execute
        .raw_response
    end
  end

  def self.query_repo_by_version(label, version_number, page:, per:)
    Rails.cache.fetch(
      "#{self.name}:#{__method__}:225:264:#{label}-#{version_number}-#{page}-#{per}",
      expires_in: CacheTTL
    ) do
      self
        .where(model_id: 298)
        .where(version_id: 358)
        .where(version_number: version_number)
        .must(match: { 'label.keyword': label })
        .page(page)
        .per(per)
        .sort(grimoire_creation_date: :desc)
        .execute
        .raw_response
    end
  end

  def self.aggs_repo_by_date(repo_url, begin_date, end_date, aggs)
    Rails.cache.fetch(
      "#{self.name}:#{__method__}:#{model_id}:#{version_id}:#{label}-#{begin_date}-#{end_date}",
      expires_in: CacheTTL
    ) do
      self
        .where(model_id: model_id)
        .where(version_id: version_id)
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
end
