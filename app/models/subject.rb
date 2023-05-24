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
#
# Indexes
#
#  index_subjects_on_label  (label) UNIQUE
#
class Subject < ApplicationRecord
  PENDING = 'pending'
  PROGRESS = 'progress'
  COMPLETE = 'complete'

  has_many :subscriptions, dependent: :destroy

  def self.task_status_converter(task_status)
    case task_status.to_s
    when ProjectTask::Success, ProjectTask::Error, ProjectTask::Canceled
      Subject::COMPLETE
    when ProjectTask::Pending, ProjectTask::Progress
      Subject::PROGRESS
    else
      Subject::PENDING
    end
  end
end
