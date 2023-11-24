# == Schema Information
#
# Table name: subject_refs
#
#  id         :bigint           not null, primary key
#  parent_id  :integer
#  child_id   :integer
#  sub_type   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_subject_refs_on_parent_id_and_child_id_and_sub_type  (parent_id,child_id,sub_type) UNIQUE
#
class SubjectRef < ApplicationRecord
  belongs_to :child, class_name: 'Subject'
  belongs_to :parent, class_name: 'Subject'

  Software = 0
  Governance = 1
end
