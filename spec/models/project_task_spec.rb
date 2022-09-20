# == Schema Information
#
# Table name: project_tasks
#
#  id           :bigint           not null, primary key
#  task_id      :string(255)
#  repo_url     :string(255)
#  status       :string(255)
#  payload      :text(65535)
#  extra        :text(65535)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  level        :string(255)
#  project_name :string(255)
#
require 'rails_helper'

RSpec.describe ProjectTask, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
