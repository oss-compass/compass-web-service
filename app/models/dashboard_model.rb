# == Schema Information
#
# Table name: dashboard_models
#
#  id                         :bigint           not null, primary key
#  name                       :string(255)      not null
#  description                :string(255)
#  dashboard_id               :integer
#  dashboard_model_info_id    :integer
#  dashboard_model_info_ident :string(255)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
class DashboardModel < ApplicationRecord
end
