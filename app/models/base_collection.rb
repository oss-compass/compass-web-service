class BaseCollection < BaseIndex
  def self.index_name
    "#{MetricsIndexPrefix}_collection"
  end
end
