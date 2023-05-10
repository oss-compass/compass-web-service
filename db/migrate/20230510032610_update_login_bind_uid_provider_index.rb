class UpdateLoginBindUidProviderIndex < ActiveRecord::Migration[7.0]
  def change
    remove_index :login_binds, [:uid, :provider], unique: true
    add_index :login_binds, [:uid, :provider_id], unique: true
  end
end
