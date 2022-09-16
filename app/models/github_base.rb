# frozen_string_literal: true

class GithubBase < IndexBase
  def self.count_by_field(origin, field: :uuid)
    self
      .must(match: { origin: origin })
      .aggregate({ count: { cardinality: { field: field }}})
      .aggregations['count']['value']
  end
end
