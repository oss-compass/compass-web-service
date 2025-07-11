# == Schema Information
#
# Table name: tracking_events
#
#  id                :bigint           not null, primary key
#  event_type        :string(255)      not null
#  timestamp         :bigint           not null
#  user_id           :integer
#  page_path         :string(255)      not null
#  module_id         :string(255)
#  referrer          :string(255)
#  device_user_agent :string(255)
#  device_language   :string(255)
#  device_timezone   :string(255)
#  data              :string(255)      not null
#  ip                :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class TrackingEvent < ApplicationRecord
  belongs_to :user, optional: true
end
