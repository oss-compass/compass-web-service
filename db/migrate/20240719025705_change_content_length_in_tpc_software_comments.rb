class ChangeContentLengthInTpcSoftwareComments < ActiveRecord::Migration[7.1]
  def change
    change_column :tpc_software_comments, :content, :string, limit: 5000
  end
end
