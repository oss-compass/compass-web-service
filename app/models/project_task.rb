# == Schema Information
#
# Table name: project_tasks
#
#  id           :bigint           not null, primary key
#  task_id      :string(255)
#  remote_url   :string(255)
#  status       :string(255)
#  payload      :text(65535)
#  extra        :text(65535)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  level        :string(255)
#  project_name :string(255)
#
# Indexes
#
#  index_project_tasks_on_project_name  (project_name) UNIQUE
#  index_project_tasks_on_remote_url    (remote_url) UNIQUE
#
class ProjectTask < ApplicationRecord
  Pending = 'pending'
  Progress = 'progress'
  Success = 'success'
  Error = 'error'
  Canceled = 'canceled'
  UnSubmit = 'unsumbit'
  Processing = [Pending, Progress]

  validates :task_id, length: { maximum: 255 }
  validates :remote_url, length: { maximum: 255 }
  validates :status, length: { maximum: 255 }
  validates :payload, length: { maximum: 65535 }
  validates :extra, length: { maximum: 65535 }
  validates :length, length: { maximum: 255 }
  validates :project_name, length: { maximum: 255 }
end
