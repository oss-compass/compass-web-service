class CreateTpcSoftwareSigs < ActiveRecord::Migration[7.1]
  def change
    create_table :tpc_software_sigs do |t|
      t.string :name, null: false
      t.string :value, null: false
      t.string :description, null: false
      t.integer :subject_id, null: false
      t.timestamps
    end
  end
end
