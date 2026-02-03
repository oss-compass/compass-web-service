# == Schema Information
#
# Table name: dashboard_metric_infos
#
#  id                      :bigint           not null, primary key
#  name                    :string(255)      not null
#  ident                   :string(255)      not null
#  category                :string(255)      not null
#  from                    :string(255)
#  default_weight          :float(24)
#  default_threshold       :float(24)
#  dashboard_model_info_id :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
class DashboardMetricInfo < ApplicationRecord

end
