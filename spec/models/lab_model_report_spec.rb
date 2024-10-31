# == Schema Information
#
# Table name: lab_model_reports
#
#  id                   :bigint           not null, primary key
#  lab_model_id         :integer          not null
#  lab_model_version_id :integer          not null
#  lab_dataset_id       :integer
#  user_id              :integer          not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  is_public            :boolean          default(FALSE)
#
require 'rails_helper'

RSpec.describe LabModelReport, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
