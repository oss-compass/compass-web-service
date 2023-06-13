# == Schema Information
#
# Table name: shortened_labels
#
#  id         :bigint           not null, primary key
#  label      :string(255)
#  short_code :string(255)
#  level      :string(255)
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
  before_validation :generate_short_code

  CharacterSet = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'

  private
  def generate_short_code
    self.short_code = Nanoid.generate(size: 7, alphabet: CharacterSet)
  end
end
