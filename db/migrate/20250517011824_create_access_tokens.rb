class CreateAccessTokens < ActiveRecord::Migration[7.1]
  def change
    create_table :access_tokens do |t|

      t.string :token, null: false
      t.integer :user_id, null: false
      t.string :name
      t.integer :type
      t.datetime :expires_at

      t.timestamps
    end

    add_index :access_tokens, :token, unique: true
    add_index :access_tokens, :user_id
    add_index :access_tokens, :expires_at
  end
end
