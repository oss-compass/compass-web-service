class RenameProjectTaskRepoUrlToRemoteUrl < ActiveRecord::Migration[7.0]
  def change
    rename_column :project_tasks, :repo_url, :remote_url
  end
end
