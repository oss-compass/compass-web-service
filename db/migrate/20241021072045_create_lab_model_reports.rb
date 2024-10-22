class CreateLabModelReports < ActiveRecord::Migration[7.1]
  def change
    create_table :lab_model_reports do |t|
      t.integer :lab_model_id, null: false
      t.integer :lab_model_version_id, null: false
      t.integer :lab_dataset_id
      t.integer :user_id, null: false
      t.timestamps
    end
  end
end
