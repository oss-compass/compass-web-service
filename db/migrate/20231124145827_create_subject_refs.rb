class CreateSubjectRefs < ActiveRecord::Migration[7.1]
  def change
    create_table :subject_refs do |t|
      t.integer :parent_id
      t.integer :child_id
      t.integer :sub_type
      t.timestamps
    end

    add_index :subject_refs, [:parent_id, :child_id, :sub_type], unique: true
  end
end
