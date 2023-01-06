# == Schema Information
#
# Table name: keywords
#
#  id         :bigint           not null, primary key
#  title      :string(255)      not null
#  desc       :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_keywords_on_title  (title)
#
require 'rails_helper'

RSpec.describe Keyword, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
