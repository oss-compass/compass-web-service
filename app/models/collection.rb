# == Schema Information
#
# Table name: collections
#
#  id         :bigint           not null, primary key
#  title      :string(255)      not null
#  desc       :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_collections_on_title  (title)
#
class Collection < ApplicationRecord
end
