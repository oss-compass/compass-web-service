class CreateSubjectSigs < ActiveRecord::Migration[7.1]
  def change
    create_table :subject_sigs do |t|
      t.string :name
      t.string :description
      t.string :maintainers
      t.string :emails
      t.integer :subject_ref_id
      t.timestamps
    end

    add_index :subject_sigs, [:subject_ref_id], unique: true
  end
end
