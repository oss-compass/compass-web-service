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
class ProjectTask < ApplicationRecord
  Pending = 'pending'
  Progress = 'progress'
  Success = 'success'
  Error = 'error'
  Canceled = 'canceled'
  UnSubmit = 'unsumbit'
  Processing = [Pending, Progress]
end
