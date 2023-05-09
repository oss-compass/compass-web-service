class CreateLoginBinds < ActiveRecord::Migration[7.0]
  def change
    create_table :login_binds do |t|
      t.belongs_to :user, null: false
      t.string :provider, null: false, index: true
      t.string :account, null: false, index: true
      t.string :nickname
      t.string :avatar_url
      t.string :uid
      t.string :provider_id
      t.timestamps
    end
    add_index :login_binds, [:uid, :provider], unique: true
  end
end
