# == Schema Information
#
# Table name: lab_model_datasets
#
#  id                   :bigint           not null, primary key
#  lab_model_version_id :integer
#  lab_dataset_id       :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
require 'rails_helper'

RSpec.describe LabModelDataset, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
