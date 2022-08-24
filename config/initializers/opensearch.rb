require 'opensearch'

class CompassSearch
  def self.client
    Thread.current[:opensearch_client] ||= OpenSearch::Client.new(
      host: ENV.fetch('OPENSEARCH_URL') { 'http://localhost:9200' },
      transport_options: { ssl: { verify: false } }  # For testing only. Use certificate for validation.
    )
  end
end
