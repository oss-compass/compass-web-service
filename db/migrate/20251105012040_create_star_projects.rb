class CreateStarProjects < ActiveRecord::Migration[7.1]
  def change
    create_table :star_projects do |t|
      t.string :project_name, comment: "项目名称"
      t.string :repo_url, comment: "代码托管网址"
      t.string :main_osdt, comment: "主导OSDT"
      t.string :level, comment: "repo或community"

      t.text :remarks, comment: "备注"


      t.timestamps
    end
  end
end
