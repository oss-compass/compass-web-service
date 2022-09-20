class RenameRepoTaskToProjectTask < ActiveRecord::Migration[7.0]
  def change
    rename_table :repo_tasks, :project_tasks
  end
end
