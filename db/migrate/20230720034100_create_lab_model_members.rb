class CreateLabModelMembers < ActiveRecord::Migration[7.0]
 def change
    create_table :lab_model_members do |t|
      t.integer :user_id, null: false
      t.integer :lab_model_id, null: false
      t.integer :permission, null: false

      t.timestamps
    end

    add_index :lab_model_members, [:lab_model_id, :user_id], unique: true
  end
end
