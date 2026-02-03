class CreateDashboardModelInfos < ActiveRecord::Migration[7.1]
  def change
    create_table :dashboard_model_infos do |t|
      t.string :name, null: false
      t.string :description, null: false
      t.string :ident

      t.timestamps
    end
  end
end
