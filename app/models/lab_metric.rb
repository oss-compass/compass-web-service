# == Schema Information
#
# Table name: lab_metrics
#
#  id                :bigint           not null, primary key
#  name              :string(255)      not null
#  ident             :string(255)      not null
#  category          :string(255)      not null
#  from              :string(255)
#  default_weight    :float(24)
#  default_threshold :float(24)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  extra             :text(65535)      default("{}")
#
class LabMetric < ApplicationRecord
  Limit = 10

  alias_attribute :weight, :default_weight
  alias_attribute :threshold, :default_threshold
  alias_attribute :metric_id, :id
  has_many :lab_model_metrics, dependent: :destroy

  validates :name, presence: true
  validates :ident, presence: true
  validates :category, presence: true

  def extra_fields
    JSON.parse(extra)['extra_fields'] rescue []
  end
end
