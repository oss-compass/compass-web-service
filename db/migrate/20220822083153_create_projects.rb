class CreateProjects < ActiveRecord::Migration[7.0]
  def change
    create_table :projects do |t|
      t.string :name
      t.string :language
      t.string :hash
      t.string :path
      t.string :backend
      t.string :html_url

      t.integer :forks_count
      t.integer :watchers_count
      t.integer :stargazers_count

      t.integer :open_issues_count
      t.timestamps
    end
  end
end
