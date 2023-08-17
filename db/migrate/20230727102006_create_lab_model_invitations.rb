class CreateLabModelInvitations < ActiveRecord::Migration[7.0]
  def change
    create_table :lab_model_invitations do |t|
      t.string :email, null: false
      t.string :token, null: false
      t.integer :lab_model_id, null: false
      t.integer :status, null: false, default: 0
      t.integer :user_id, null: false
      t.text :extra

      t.timestamps
    end

    add_index :lab_model_invitations, :lab_model_id
  end
end
