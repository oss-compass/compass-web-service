class AddSomeUniqueIndicesForProjectTasks < ActiveRecord::Migration[7.0]
  def change
    add_index :project_tasks, :remote_url, :unique => true
    add_index :project_tasks, :project_name, :unique => true
  end
end
