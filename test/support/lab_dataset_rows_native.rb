# Focused native runner. Normal Rails test runs use test_helper instead.
require 'rails'
require 'active_record'
require 'active_support/all'
require 'active_support/test_case'
require 'minitest/autorun'
require 'graphql'
require 'zeitwerk'
require 'addressable/uri'
require 'nanoid'
require 'securerandom'
require 'uri'

root = File.expand_path('../..', __dir__)
database = ENV.fetch('COMPASS_DATASET_DATABASE')
unless database == 'compass_dataset_rows_test'
  raise ArgumentError, 'the focused runner requires its disposable compass_dataset_rows_test database'
end

Rails.env = 'test'
Rails.cache = ActiveSupport::Cache::MemoryStore.new
I18n.load_path << File.join(root, 'config/locales/en.yml')
ActiveRecord::Base.establish_connection(
  adapter: 'mysql2',
  host: ENV.fetch('COMPASS_DATASET_HOST', '127.0.0.1'),
  port: ENV.fetch('COMPASS_DATASET_PORT', '3306').to_i,
  username: ENV.fetch('COMPASS_DATASET_USER'),
  password: ENV.fetch('COMPASS_DATASET_PASSWORD'),
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

  create_table :lab_datasets, force: true do |table|
    table.string :ident
    table.string :name
    table.integer :lab_model_version_id, null: false
    table.text :content
    table.integer :user_id
    table.bigint :lab_model_report_id
    table.timestamps
  end
end

require_relative '../../app/models/application_record'
require_relative '../../app/models/shortened_label'
require_relative '../../app/models/lab_dataset'

loader = Zeitwerk::Loader.new
loader.push_dir(File.join(root, 'app/graphql'))
loader.setup

puts "Native dataset checks: Ruby #{RUBY_VERSION}, GraphQL #{GraphQL::VERSION}, " \
     "Active Record #{ActiveRecord::VERSION::STRING}, " \
     "MariaDB #{ActiveRecord::Base.connection.select_value('SELECT VERSION()')}"
