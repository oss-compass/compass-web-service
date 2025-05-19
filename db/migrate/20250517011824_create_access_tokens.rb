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
  end
end
