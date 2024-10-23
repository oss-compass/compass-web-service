# == Schema Information
#
# Table name: shortened_labels
#
#  id         :bigint           not null, primary key
#  label      :string(255)      not null
#  short_code :string(255)      not null
#  level      :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_shortened_labels_on_label_and_level  (label,level) UNIQUE
#  index_shortened_labels_on_short_code       (short_code) UNIQUE
#
class ShortenedLabel < ApplicationRecord
  validates :short_code, presence: true, uniqueness: true
  validates :label, presence: true
  validates :level, presence: true
  before_validation :generate_short_code

  CacheTTL = 1.week
  CharacterSet = '0123456789abcdefghijklmnopqrstuvwxyz'
  Bucket = 'shortened_labels'

  def self.convert(label, level)
    label = normalize_label(label)
    key = "#{self.name}:#{level}:#{label}"
    cached_short_code = nil
    cached_short_code = CompassRiak.get(Bucket, key) if Rails.env.production?
    return cached_short_code if cached_short_code
    Rails.cache.fetch(key, expires_in: CacheTTL) do
      code = ShortenedLabel.find_or_create_by(label: label, level: level).short_code
      CompassRiak.put(Bucket, key, code) if code && Rails.env.production?
      code
    end
  end

  def self.revert(short_code)
    short = nil
    normalize_short_code = short_code.to_s.downcase
    key = "#{self.name}:#{normalize_short_code}"
    short = CompassRiak.get(Bucket, key) if Rails.env.production?
    return short if short
    short = Rails.cache.read(key)
    return short if short
    short = ShortenedLabel.find_by(short_code: normalize_short_code)
    Rails.cache.write(key, short, expires_in: CacheTTL) if short
    CompassRiak.put(Bucket, key, code) if short && Rails.env.production?
    short
  end

  def self.expire_cache(label, level)
    label = normalize_label(label)
    Rails.cache.delete("#{self.name}:#{level}:#{label}")
  end

  def self.normalize_label(label)
    if label =~ URI::regexp
      uri = Addressable::URI.parse(label)
      "#{uri&.scheme}://#{uri&.normalized_host}#{uri&.path}"
    else
      label
    end
  end

  private
  def generate_short_code
    self.short_code = loop do
      nanoid = Nanoid.generate(size: 7, alphabet: CharacterSet)
      short_code = "#{self.level == 'repo' ? 's' : 'c'}#{nanoid}"
      break short_code unless ShortenedLabel.exists?(short_code: short_code)
    end
  end
end
