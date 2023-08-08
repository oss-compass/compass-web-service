# frozen_string_literal: true

module Censoring
  extend ActiveSupport::Concern

  Enable = ENV.fetch('CENSORING_ENABLE') { false }
  Host = ENV.fetch('DEFAULT_HOST') { 'http://localhost:3000' }
  AppNumber = 4
  CensoringTopic = 'compass-review'
  CensoringPrefix = 'censoring_result'
  Failed = '0'
  Approved = '1'

  ClassIds = {
    'LabModel' => 0,
    'LoginBind' => 1,
  }

  def enum_id
    ClassIds["#{self.class}"] || -1
  end

  def censoring_key(field)
    "#{Host}:cache:#{CensoringPrefix}:#{enum_id}:#{self.id}:#{field}"
  end

  def censoring_result(field)
    Rails.cache.redis.get(censoring_key(field)) rescue nil
  end

  def processing_censoring(field, type: 'text', is_attr: true)
    key = field
    value = is_attr ? self[field] : send(field)
    if type == 'image'
      type = 'url'
      key = 'url'
      value = value.starts_with?('http') ? value : Addressable::URI.join(Host, value).to_s
    end
    body = {
      redis_key: censoring_key(field),
      origin_url: Host,
      gvp: false, # whilelist
      author_id: nil,
      app_name: AppNumber,
      resource: enum_id,
      resource_type: self.class.to_s,
      resource_id: self.id,
      repository: 0, # whilelist
      repository_url: Host,
      user_id: nil,
      type: type,
      data: { key => "#{value}" }
    }
    CompassKafka.pool.with do |producer|
      producer.produce_async(topic: CensoringTopic, payload: body.to_json)
    end
  end

  def censoring_update
    return unless Enable
    change_keys = self.previous_changes.keys
    change_censoring_attributes = change_keys & self.censoring_attributes.map(&:to_s)
    change_censoring_images = change_keys & self.censoring_img_attributes.map(&:to_s)

    if change_censoring_attributes != []
      change_censoring_attributes.map { |field| processing_censoring(field) }
    end

    if change_censoring_images != []
      change_censoring_images.map { |image_field| processing_censoring(image_field, type: 'image') }
    end
  end

  module ClassMethods

    def censoring(options = {})
      class_attribute :censoring_options, instance_writer: false
      class_attribute :censoring_attributes, instance_writer: false
      class_attribute :censoring_img_attributes, instance_writer: false
      class_attribute :censoring_internal_attrs, instance_writer: false

      self.censoring_options = options
      self.censoring_attributes = options[:only] || []
      self.censoring_img_attributes = options[:img] || []
      self.censoring_internal_attrs = options[:attrs] || []

      after_commit :censoring_update, on: [:create, :update]

      censoring_attributes.each do |key|
        define_method("#{key}_after_reviewed") do
          is_attr = self.censoring_internal_attrs.include?(key)
          return is_attr ? self[key] : send(key) unless Enable
          result = censoring_result(key)
          return I18n.t('censoring.illegal') if result == Failed
          processing_censoring(key, type: 'text', is_attr: is_attr) if result.nil?
          is_attr ? self[key] : send(key)
        end
      end

      censoring_img_attributes.each do |key|
        define_method("#{key}_after_reviewed") do
          is_attr = self.censoring_internal_attrs.include?(key)
          return is_attr ? self[key] : send(key) unless Enable
          result = censoring_result(key)
          return Addressable::URI.join(Host, I18n.t('censoring.illegal_img')).to_s if result == Failed
          processing_censoring(key, type: 'image', is_attr: is_attr) if result.nil?
          is_attr ? self[key] : send(key)
        end
      end
    end
  end
end
