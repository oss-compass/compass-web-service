class AddAnonymousToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :anonymous, :boolean, default: false
  end
end
