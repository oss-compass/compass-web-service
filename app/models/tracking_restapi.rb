# == Schema Information
#
# Table name: tracking_restapis
#
#  id         :bigint           not null, primary key
#  user_id    :integer
#  api_path   :string(255)      not null
#  domain     :string(255)      not null
#  ip         :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class TrackingRestapi < ApplicationRecord
  belongs_to :user
end
