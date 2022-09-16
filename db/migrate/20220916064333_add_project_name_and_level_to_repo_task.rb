class AddProjectNameAndLevelToRepoTask < ActiveRecord::Migration[7.0]
  def change
    add_column :repo_tasks, :level, :string
    add_column :repo_tasks, :project_name, :string
  end
end
