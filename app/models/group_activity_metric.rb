class GroupActivityMetric < BaseMetric
  def self.index_name
    "#{MetricsIndexPrefix}_group_activity"
  end

  def self.aggs_repo_by_date(repo_url, begin_date, end_date, aggs)
    Rails.cache.fetch(
      "#{self.name}-#{__method__}-#{repo_url}-#{begin_date}-#{end_date}",
      expires_in: CacheTTL
    ) do
      self
        .must(match: { 'label.keyword': repo_url })
        .where(is_org: true)
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
