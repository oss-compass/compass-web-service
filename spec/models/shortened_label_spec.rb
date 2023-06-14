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
require 'rails_helper'

RSpec.describe ShortenedLabel, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
