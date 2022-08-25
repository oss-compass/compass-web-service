class CreateRepoTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :repo_tasks do |t|
      t.string :task_id, null: false
      t.string :repo_url, null: false
      t.string :status
      t.text :payload
      t.text :extra

      t.timestamps
    end
  end
end
