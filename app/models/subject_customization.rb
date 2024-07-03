# == Schema Information
#
# Table name: subject_customizations
#
#  id                    :bigint           not null, primary key
#  name                  :string(255)
#  subject_id            :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  tpc_software_tag_mail :string(500)
#
# Indexes
#
#  index_subject_customizations_on_subject_id  (subject_id) UNIQUE
#
class SubjectCustomization < ApplicationRecord
  belongs_to :subject

end
