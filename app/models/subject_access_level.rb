# == Schema Information
#
# Table name: subject_access_levels
#
#  id           :bigint           not null, primary key
#  subject_id   :integer          not null
#  access_level :integer          default(0), not null
#  user_id      :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_subject_access_levels_on_user_id_and_subject_id  (user_id,subject_id) UNIQUE
#
class SubjectAccessLevel < ApplicationRecord
  NOMAL_LEVEL = 0
  PRIVILEGED_LEVEL = 1
  belongs_to :user
  belongs_to :subject
end
