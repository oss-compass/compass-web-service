class AddRoleLevelToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :role_level, :integer, default: 0, null: false
  end
end
