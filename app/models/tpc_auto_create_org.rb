# == Schema Information
#
# Table name: tpc_auto_create_orgs
#
#  id         :bigint           not null, primary key
#  org_url    :string(255)      not null
#  name       :string(255)
#  enabled    :boolean          default(TRUE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class TpcAutoCreateOrg < ApplicationRecord

  has_many :tpc_auto_create_committers

  scope :enabled, -> { where(enabled: true) }
end
