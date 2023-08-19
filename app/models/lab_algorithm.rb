# == Schema Information
#
# Table name: lab_algorithms
#
#  id         :bigint           not null, primary key
#  ident      :string(255)      not null
#  extra      :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class LabAlgorithm < ApplicationRecord
  has_many :lab_model_versions

  validates :ident, presence: true

  def name
    ident
  end

  def default
    'criticality_score'
  end
end
