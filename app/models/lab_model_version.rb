# == Schema Information
#
# Table name: lab_model_versions
#
#  id                          :bigint           not null, primary key
#  version                     :string(255)      default("")
#  lab_model_id                :integer          not null
#  lab_dataset_id              :integer          not null
#  lab_algorithm_id            :integer          not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  is_score                    :boolean          default(FALSE)
#  parent_lab_model_version_id :bigint
#
# Indexes
#
#  index_lab_model_versions_on_lab_model_id_and_version  (lab_model_id,version)
#
class LabModelVersion < ApplicationRecord
  alias_attribute :dataset, :lab_dataset
  alias_attribute :report, :lab_model_report
  alias_attribute :algorithm, :lab_algorithm
  alias_attribute :metrics, :lab_model_metrics
  alias_attribute :comments, :lab_model_comments

  validates :lab_dataset_id, presence: true
  validates :lab_algorithm_id, presence: true

  has_one :lab_dataset, dependent: :delete
  belongs_to :lab_algorithm
  belongs_to :lab_model
  has_many :lab_model_metrics, dependent: :destroy
  has_many :lab_model_reports, dependent: :destroy
  has_many :lab_model_comments, dependent: :destroy
  has_many :lab_metrics, through: :lab_model_metrics

  before_validation :set_initial_version

  def set_initial_version
    self.version = 'v0.0.1' if self.version&.strip&.blank?
  end

  def bulk_update_or_create!(metrics)
    ActiveRecord::Base.transaction do
      keep_metrics_ids =
        metrics.map do |metric|
        new_metric = self.metrics.find_or_initialize_by(lab_metric: LabMetric.find_by(id: metric.id))
        new_metric.weight = metric.weight
        new_metric.threshold = metric.threshold
        new_metric.save!

        new_metric.id
      end
      self.metrics.where.not(id: keep_metrics_ids).destroy_all
    end
  end

  def trigger_status
    CustomAnalyzeReportServer.new({user: nil, model: lab_model, version: self}).check_task_status
  end

  def trigger_updated_at
    CustomAnalyzeReportServer.new({user: nil, model: lab_model, version: self}).check_task_updated_time
  end
end
