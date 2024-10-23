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
#
class LabModelReport < ApplicationRecord
  alias_attribute :versions, :lab_model_versions
  alias_attribute :dataset, :lab_dataset
  alias_attribute :metrics, :lab_model_metrics

  belongs_to :lab_model_version
  belongs_to :lab_model

  has_one :lab_dataset, dependent: :delete

  def algorithm
    lab_model_version.algorithm if lab_model_version.present?
  end

  def metrics
    lab_model_version.metrics
  end

  def trigger_status
    CustomAnalyzeReportServer.new({ user: nil, model: lab_model, version: lab_model_version, report: self }).check_task_status
  end

  def trigger_updated_at
    CustomAnalyzeReportServer.new({ user: nil, model: lab_model, version: lab_model_version, report: self }).check_task_updated_time
  end

end
