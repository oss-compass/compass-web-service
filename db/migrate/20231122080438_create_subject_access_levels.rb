class CreateSubjectAccessLevels < ActiveRecord::Migration[7.1]
  def change
    create_table :subject_access_levels do |t|
      t.integer :subject_id, null: false
      t.integer :access_level, default: 0, null: false
      t.integer :user_id, null: false

      t.timestamps
    end
    add_index :subject_access_levels, [:user_id, :subject_id], unique: true
  end
end
