# == Schema Information
#
# Table name: project_keyword_refs
#
#  id           :bigint           not null, primary key
#  project_name :string(255)      not null
#  keyword_id   :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_project_keyword_refs_on_keyword_id                   (keyword_id)
#  index_project_keyword_refs_on_project_name                 (project_name)
#  index_project_keyword_refs_on_project_name_and_keyword_id  (project_name,keyword_id) UNIQUE
#
class ProjectKeywordRef < ApplicationRecord
  belongs_to :keyword
end
