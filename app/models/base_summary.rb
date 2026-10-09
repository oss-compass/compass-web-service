class BaseSummary < BaseIndex
  def self.query_by_date(begin_date, end_date, page: 1, per: 60, category: nil)
    Rails.cache.fetch(
      "#{self.name}-#{__method__}-#{begin_date}-#{end_date}-#{page}-#{per}" \
        "#{category_cache_segment(category)}",
      expires_in: CacheTTL
    ) do
    chain =
      self
        .page(page)
        .per(per)
        .range(:grimoire_creation_date, gte: begin_date, lte: end_date)
        .sort(grimoire_creation_date: :asc)
    apply_category_scope(chain, category).execute.raw_response
    end
  end

  def self.aggs_by_date(begin_date, end_date, aggs, category: nil)
    Rails.cache.fetch(
      "#{self.name}-#{__method__}-#{begin_date}-#{end_date}" \
        "#{category_cache_segment(category)}",
      expires_in: CacheTTL
    ) do
    chain =
      self
        .page(1)
        .per(1)
        .range(:grimoire_creation_date, gte: begin_date, lte: end_date)
        .sort(grimoire_creation_date: :asc)
        .aggregate(aggs)
    apply_category_scope(chain, category).execute.raw_response
    end
  end

  # 缓存键的分类片段。全局请求**不加**任何片段，
  # 使原有的全局缓存键逐字不变（对应验收条目 A01「原有全局请求保持兼容」）。
  def self.category_cache_segment(category)
    category.nil? ? '' : "-category=#{category}"
  end

  # 按分类限定查询。
  # - 传了分类：只取本分类的文档；
  # - 没传分类（全局）：**排除**带 category 的文档。
  #   落点 2/3 之后同一索引里同时躺着全局文档与分类文档，
  #   不加这一条，全局统计会把各分类文档也算进来。
  def self.apply_category_scope(chain, category)
    return chain.must_not(exists: { field: 'category' }) if category.nil?

    chain.where('category' => category)
  end
end
