# frozen_string_literal: true
module Userable
  extend ActiveSupport::Concern

  included do
    def self.serialize_from_session(key, salt)
      single_key = key.is_a?(Array) ? key.first : key
      record = Rails.env.production? ? CompassRiak.get('users', "user_#{single_key}") : nil
      return record if record && record.authenticatable_salt == salt
      record = to_adapter.get(key)
      return record if record && record.authenticatable_salt == salt && CompassRiak.put('users', "user_#{single_key}", record)
      super
    end
  end
end
