# == Schema Information
#
# Table name: feedbacks
#
#  id         :bigint           not null, primary key
#  module     :string(255)      not null
#  content    :string(255)      not null
#  page       :string(255)
#  user_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Feedback < ApplicationRecord
  belongs_to :user
end
