class GithubBase
  include SearchFlip::Index
  def self.connection
    AuthSearchConn
  end

  def self.count_by_field(origin, field: :uuid)
    self
      .must(match: { origin: origin })
      .aggregate({ count: { cardinality: { field: field }}})
      .aggregations['count']['value']
  end
end
