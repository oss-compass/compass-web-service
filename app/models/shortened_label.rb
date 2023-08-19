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

  def self.convert(label, level)
    label = normalize_label(label)
    Rails.cache.fetch("#{self.name}:#{level}:#{label}", expires_in: CacheTTL) do
      ShortenedLabel.find_or_create_by(label: label, level: level).short_code
    end
  end

  def self.revert(short_code)
    short = Rails.cache.read("#{self.name}:#{short_code.to_s.downcase}")
    return short if short
    short = ShortenedLabel.find_by(short_code: short_code.to_s.downcase)
    Rails.cache.write("#{self.name}:#{short.short_code}", short, expires_in: CacheTTL) if short
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
