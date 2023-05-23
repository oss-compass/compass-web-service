# == Schema Information
#
# Table name: subscriptions
#
#  id         :bigint           not null, primary key
#  user_id    :bigint           not null
#  subject_id :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_subscriptions_on_user_id_and_subject_id  (user_id,subject_id) UNIQUE
#
require 'rails_helper'

RSpec.describe Subscription, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
