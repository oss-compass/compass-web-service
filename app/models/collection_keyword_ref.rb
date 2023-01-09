# == Schema Information
#
# Table name: collection_keyword_refs
#
#  id            :bigint           not null, primary key
#  collection_id :integer          not null
#  keyword_id    :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_collection_keyword_refs_on_collection_id                 (collection_id)
#  index_collection_keyword_refs_on_collection_id_and_keyword_id  (collection_id,keyword_id) UNIQUE
#  index_collection_keyword_refs_on_keyword_id                    (keyword_id)
#
class CollectionKeywordRef < ApplicationRecord
  belongs_to :collection
  belongs_to :keyword
end
