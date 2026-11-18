# frozen_string_literal: true

http_client = SearchFlip::HTTPClient.new

# Basic Auth
http_client = http_client.basic_auth(
  user: ENV.fetch('OPENSEARCH_USER') { 'user' },
  pass: ENV.fetch('OPENSEARCH_PASS') { 'pass' }
)

# Timeouts
# 全局超时（单次请求的总耗时预算）。默认 20 秒对聚合/scroll 类查询偏紧，
# 可通过 OPENSEARCH_TIMEOUT（秒）调整。
http_client = http_client.timeout(ENV.fetch('OPENSEARCH_TIMEOUT', 60).to_i)

AuthSearchConn = SearchFlip::Connection.new(
  base_url: ENV.fetch('OPENSEARCH_URL') { 'http://localhost:9200' },
  http_client: http_client
)
AuthSearchConn.define_singleton_method(:version) do
  "7.10.2"
end
