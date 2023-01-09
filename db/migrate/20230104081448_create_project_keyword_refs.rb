class CreateProjectKeywordRefs < ActiveRecord::Migration[7.0]
  def change
    create_table :project_keyword_refs do |t|
      t.string :project_name, null: false
      t.integer :keyword_id, null: false

      t.timestamps
    end

    add_index :project_keyword_refs, :project_name
    add_index :project_keyword_refs, :keyword_id
    add_index :project_keyword_refs, [:project_name, :keyword_id], unique: true, using: :btree
  end
end
