class CreateSubjectCustomizations < ActiveRecord::Migration[7.1]
  def change
    create_table :subject_customizations do |t|
      t.string :name
      t.integer :subject_id
      t.timestamps
    end

    add_index :subject_customizations, [:subject_id], unique: true
  end
end
