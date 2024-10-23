# == Schema Information
#
# Table name: lab_model_metrics
#
#  id                   :bigint           not null, primary key
#  lab_metric_id        :integer          not null
#  lab_model_version_id :integer          not null
#  weight               :float(24)
#  threshold            :float(24)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_metrics_on_v_m  (lab_model_version_id,lab_metric_id)
#
class LabModelMetric < ApplicationRecord
  alias_attribute :comments, :lab_model_comments


  belongs_to :lab_model_version
  belongs_to :lab_metric
  has_many :lab_model_comments, dependent: :destroy # need to purge attachments

  delegate :name, to: :lab_metric
  delegate :ident, to: :lab_metric
  delegate :category, to: :lab_metric
  delegate :extra_fields, to: :lab_metric
  delegate :from, to: :lab_metric
  delegate :default_weight, to: :lab_metric
  delegate :default_threshold, to: :lab_metric
  delegate :metric_id, to: :lab_metric

  def self.bulk_create_and_validate!(version, metrics)
    lab_metrics =
      metrics.map do |metric|
      {
        lab_metric: LabMetric.find_by(id: metric.id),
        weight: metric.weight,
        threshold: metric.threshold
      }
    end
    version.lab_model_metrics.create!(lab_metrics)
  end

  def self.create_by_version(version, metrics)
    lab_metrics =
      metrics.map do |metric|
        {
          lab_metric_id: metric.lab_metric_id,
          weight: metric.weight,
          threshold: metric.threshold,
          lab_model_version_id: version.id
        }
      end
    LabModelMetric.create!(lab_metrics)
  end
end
