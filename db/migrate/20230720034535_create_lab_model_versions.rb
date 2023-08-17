class CreateLabModelVersions < ActiveRecord::Migration[7.0]
 def change
    create_table :lab_model_versions do |t|
      t.string :version, default: ""
      t.integer :lab_model_id, null: false
      t.integer :lab_dataset_id, null: false
      t.integer :lab_algorithm_id, null: false

      t.timestamps
    end

    add_index :lab_model_versions, [:lab_model_id, :version]
  end
end
