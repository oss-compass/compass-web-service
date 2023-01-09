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
  has_many :project_collection_refs, dependent: :delete_all
  has_many :collection_keyword_refs, dependent: :delete_all
  has_many :keywords, through: :collection_keyword_refs

  def projects
    project_collection_refs.select(:project_name).map(&:project_name)
  end
end
