# == Schema Information
#
# Table name: subject_sigs
#
#  id               :bigint           not null, primary key
#  name             :string
#  description      :string
#  maintainers      :string
#  emails           :string
#  subject_ref_id   :integer
#  created_at       :datetime
#  updated_at       :datetime
#
# Indexes
#
#  index_subject_sigs_on_subject_ref_id  (subject_ref_id) UNIQUE
#
class SubjectSig < ApplicationRecord
  belongs_to :subject_ref


end
