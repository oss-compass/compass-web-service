class CreateProjectCollectionRefs < ActiveRecord::Migration[7.0]

  def change
    create_table :project_collection_refs do |t|
      t.string :project_name, null: false
      t.integer :collection_id, null: false

      t.timestamps
    end

    add_index :project_collection_refs, :project_name
    add_index :project_collection_refs, :collection_id
    add_index :project_collection_refs, [:project_name, :collection_id], unique: true, using: :btree
  end
end
