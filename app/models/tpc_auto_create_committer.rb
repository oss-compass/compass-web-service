# == Schema Information
#
# Table name: tpc_auto_create_committers
#
#  id                     :bigint           not null, primary key
#  tpc_auto_create_org_id :integer          not null
#  gitcode_account        :string(255)      not null
#  role                   :string(255)      default("push")
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class TpcAutoCreateCommitter < ApplicationRecord
  belongs_to :tpc_auto_create_org, foreign_key: 'tpc_auto_create_org_id'
end
