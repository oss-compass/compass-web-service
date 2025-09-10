# == Schema Information
#
# Table name: mq_metrics
#
#  id             :bigint           not null, primary key
#  total          :integer
#  ready          :integer
#  unacknowledged :integer
#  consumers      :integer
#  queue_name     :string(255)
#  queue_type     :string(255)
#  belong_to      :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class MqMetric < ApplicationRecord
end
