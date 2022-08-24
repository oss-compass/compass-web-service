# frozen_string_literal: true

http_client = SearchFlip::HTTPClient.new

# Basic Auth
http_client = http_client.basic_auth(
  user: ENV.fetch('OPENSEARCH_USER') { 'user' },
  pass: ENV.fetch('OPENSEARCH_PASS') { 'pass' }
)

# Timeouts
http_client = http_client.timeout(20)

AuthSearchConn = SearchFlip::Connection.new(
  base_url: ENV.fetch('OPENSEARCH_URL') { 'http://localhost:9200' },
  http_client: http_client
)
