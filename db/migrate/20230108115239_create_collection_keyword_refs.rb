class CreateCollectionKeywordRefs < ActiveRecord::Migration[7.0]
  def change
    create_table :collection_keyword_refs do |t|
      t.integer :collection_id, null: false
      t.integer :keyword_id, null: false

      t.timestamps
    end

    add_index :collection_keyword_refs, :collection_id
    add_index :collection_keyword_refs, :keyword_id
    add_index :collection_keyword_refs, [:collection_id, :keyword_id], unique: true, using: :btree
  end
end
