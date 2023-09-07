class ChangeRemoteUrlCollationOfProjectTask < ActiveRecord::Migration[7.0]
  def up
    change_column :project_tasks, :remote_url, :string, limit: 255, collation: 'utf8mb4_bin'
  end

  def down
    change_column :project_tasks, :remote_url, :string, limit: 255, collation: 'utf8mb4_general_ci'
  end
end
