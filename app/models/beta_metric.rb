# == Schema Information
#
# Table name: beta_metrics
#
#  id             :bigint           not null, primary key
#  dimensionality :string(255)
#  metric         :string(255)
#  desc           :string(255)
#  status         :string(255)
#  workflow       :string(255)
#  project        :string(255)
#  op_index       :string(255)
#  op_metric      :string(255)
#  extra          :text(65535)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class BetaMetric < ApplicationRecord
end
