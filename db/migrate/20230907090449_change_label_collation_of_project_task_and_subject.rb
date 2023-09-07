class ChangeLabelCollationOfProjectTaskAndSubject < ActiveRecord::Migration[7.0]
  def up
    change_column :subjects, :label, :string, limit: 255, collation: 'utf8mb4_bin'
    change_column :project_tasks, :project_name, :string, limit: 255, collation: 'utf8mb4_bin'
  end

  def down
    change_column :subjects, :label, :string, limit: 255, collation: 'utf8mb4_general_ci'
    change_column :project_tasks, :project_name, :string, limit: 255, collation: 'utf8mb4_general_ci'
  end
end
