# == Schema Information
#
# Table name: project_collection_refs
#
#  id            :bigint           not null, primary key
#  project_name  :string(255)      not null
#  collection_id :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_project_collection_refs_on_collection_id                   (collection_id)
#  index_project_collection_refs_on_project_name                    (project_name)
#  index_project_collection_refs_on_project_name_and_collection_id  (project_name,collection_id) UNIQUE
#
class ProjectCollectionRef < ApplicationRecord
end
