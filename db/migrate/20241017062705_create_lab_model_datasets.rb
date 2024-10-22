class CreateLabModelDatasets < ActiveRecord::Migration[7.1]
  def change
    create_table :lab_model_datasets do |t|
      t.integer :lab_model_version_id
      t.integer :lab_dataset_id

      t.timestamps
    end
  end
end
