class CreateLabModelComments < ActiveRecord::Migration[7.0]
  def change
    create_table :lab_model_comments do |t|
      t.integer :user_id, null: false
      t.text :content, null: false
      t.integer :reply_to, null: true
      t.integer :lab_model_id, null: false

      t.integer :lab_model_version_id, null: true
      t.integer :lab_model_metric_id, null: true

      t.timestamps
    end

    add_index :lab_model_comments, [:lab_model_id, :lab_model_version_id, :lab_model_metric_id], name: "index_comments_on_m_v_m", using: :btree
    add_index :lab_model_comments, :user_id
    add_index :lab_model_comments, :reply_to
  end
end
