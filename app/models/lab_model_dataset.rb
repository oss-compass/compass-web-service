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
class LabModelDataset < ApplicationRecord

end
