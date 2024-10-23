require 'connection_pool'

RIAK_PRODUCERS_CP = ConnectionPool.new do
  Riak::Client.new(
    host: ENV.fetch('RIAK_HOST') { 'localhost' },
    pb_port: ENV.fetch('RIAK_PORT') { 8087 }
  )
end

class CompassRiak
  MARSHAL_SIGNATURE = "\x04\x08".freeze

  def self.pool
    RIAK_PRODUCERS_CP
  end

  def self.get(bucket, key, bucket_type: 'default')
    pool.with do |client|
      object = client.bucket_type(bucket_type).bucket(bucket).get(key)
      needs_decode?(object.data) ? Marshal.load(object.data) : object.data
    end
  rescue
    nil
  end

  def self.delete(bucket, key)
    pool.with do |client|
      client.bucket(bucket).delete(key)
    end
  end

  def self.put(bucket, key, value, bucket_type: 'default')
    pool.with do |client|
      object = client.bucket_type(bucket_type).bucket(bucket).new(key)
      object.data = Marshal.dump(value)
      object.content_type = 'application/x-ruby-marshal'
      object.store
    end
  end

  def self.needs_decode?(value)
    value.start_with?(MARSHAL_SIGNATURE)
  end
end
