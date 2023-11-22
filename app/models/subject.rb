# == Schema Information
#
# Table name: subjects
#
#  id                :bigint           not null, primary key
#  label             :string(255)      not null
#  level             :string(255)      default("repo"), not null
#  status            :string(255)      default("pending"), not null
#  count             :integer          default(0), not null
#  status_updated_at :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  collect_at        :datetime
#  complete_at       :datetime
#
# Indexes
#
#  index_subjects_on_label  (label) UNIQUE
#
class Subject < ApplicationRecord
  PENDING = 'pending'
  PROGRESS = 'progress'
  COMPLETE = 'complete'
  UNKNOWN = 'unknown'

  has_many :subscriptions, dependent: :destroy
  has_many :subject_access_levels, dependent: :destroy

  validates :label, presence: true, length: { maximum: 255 }
  validates :level, presence: true, length: { maximum: 255 }
  validates :status, presence: true, length: { maximum: 255 }
  validates :count, presence: true

  def self.task_status_converter(task_status)
    case task_status.to_s
    when ProjectTask::Success, ProjectTask::Error, ProjectTask::Canceled
      COMPLETE
    when ProjectTask::Progress
      PROGRESS
    when ProjectTask::Pending
      PENDING
    else
      UNKNOWN
    end
  end

  def add_privileged_access_level!(user)
    return if user.blank?
    new_access_level = subject_access_levels.find_or_initialize_by(user: user)
    new_access_level.access_level = SubjectAccessLevel::PRIVILEGED_LEVEL
    new_access_level.save!
  end
end
