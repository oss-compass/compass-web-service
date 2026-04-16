# == Schema Information
#
# Table name: dashboard_community_responsible_people
#
#  id           :bigint           not null, primary key
#  dashboard_id :bigint
#  user_id      :bigint
#  label        :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_dashboard_community_responsible_people_on_dashboard_id  (dashboard_id)
#  index_dashboard_community_responsible_people_on_user_id       (user_id)
#
class DashboardCommunityResponsiblePerson < ApplicationRecord
  belongs_to :user
end
