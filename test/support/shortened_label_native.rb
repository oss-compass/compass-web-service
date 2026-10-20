# Optional focused runner for a disposable MariaDB instance. Normal Rails test
# runs use test_helper instead and do not execute this database setup.
require 'rails'
require 'active_record'
require 'active_support/test_case'
require 'active_support/cache'
require 'active_support/core_ext/numeric/time'
require 'minitest/autorun'
require 'addressable/uri'
require 'nanoid'
require 'securerandom'
require 'uri'

database = ENV.fetch('COMPASS_SHORT_LABEL_DATABASE')
unless database == 'compass_short_label_test'
  raise ArgumentError, 'the focused runner requires its disposable compass_short_label_test database'
end

Rails.env = 'test'
Rails.cache = ActiveSupport::Cache::MemoryStore.new
ActiveRecord::Base.establish_connection(
  adapter: 'mysql2',
  host: ENV.fetch('COMPASS_SHORT_LABEL_HOST', '127.0.0.1'),
  port: ENV.fetch('COMPASS_SHORT_LABEL_PORT', '3306').to_i,
  username: ENV.fetch('COMPASS_SHORT_LABEL_USER'),
  password: ENV.fetch('COMPASS_SHORT_LABEL_PASSWORD'),
  database: database
)

ActiveRecord::Schema.verbose = false
ActiveRecord::Schema.define do
  create_table :shortened_labels, force: true do |table|
    table.string :label, null: false
    table.string :short_code, null: false
    table.string :level, null: false
    table.timestamps
  end
  add_index :shortened_labels, [:label, :level], unique: true
  add_index :shortened_labels, :short_code, unique: true
end

require_relative '../../app/models/application_record'
require_relative '../../app/models/shortened_label'

puts "Native model checks: Ruby #{RUBY_VERSION}, Active Record #{ActiveRecord::VERSION::STRING}, " \
     "MariaDB #{ActiveRecord::Base.connection.select_value('SELECT VERSION()')}"
