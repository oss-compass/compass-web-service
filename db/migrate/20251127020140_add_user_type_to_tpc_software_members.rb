class AddUserTypeToTpcSoftwareMembers < ActiveRecord::Migration[7.1]
  def change
    add_column :tpc_software_members, :gitcode_account, :string
  end
end
