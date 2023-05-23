class CreateSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :subscriptions do |t|
      t.bigint :user_id, null: false
      t.bigint :subject_id, null: false
      t.timestamps
    end
    add_index :subscriptions, [:user_id, :subject_id], unique: true
  end
end
