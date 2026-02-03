# == Schema Information
#
# Table name: dashboard_model_infos
#
#  id          :bigint           not null, primary key
#  name        :string(255)      not null
#  description :string(255)      not null
#  ident       :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class DashboardModelInfo < ApplicationRecord

  has_many :dashboard_metric_infos, foreign_key: :dashboard_model_info_id
end
