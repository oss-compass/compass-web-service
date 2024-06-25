# == Schema Information
#
# Table name: tpc_software_selections
#
#  id                                :bigint           not null, primary key
#  selection_type                    :integer          not null
#  tpc_software_selection_report_ids :string(255)      not null
#  repo_url                          :string(255)
#  committers                        :string(255)      not null
#  incubation_time                   :datetime         not null
#  adaptation_method                 :integer          not null
#  reason                            :string(255)      not null
#  issue_url                         :string(255)
#  subject_id                        :integer          not null
#  user_id                           :integer          not null
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#
class TpcSoftwareSelection < ApplicationRecord

  belongs_to :subject
  belongs_to :user
  has_many :tpc_software_output_reports


  Adaptation_Method_Adaptation = 0
  Adaptation_Method_Rewrite = 1

end
