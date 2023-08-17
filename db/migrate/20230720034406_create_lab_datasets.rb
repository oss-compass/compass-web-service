class CreateLabDatasets < ActiveRecord::Migration[7.0]
 def change
   create_table :lab_datasets do |t|
     t.string :ident
     t.string :name
     t.integer :lab_model_version_id, null: false
     t.text :content
     t.timestamps
    end
  end
end
