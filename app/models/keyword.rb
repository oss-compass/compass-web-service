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
class Keyword < ApplicationRecord

  has_many :collections
  has_many :project_keyword_refs
end
