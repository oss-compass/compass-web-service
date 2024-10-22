class AddUserIdToLabDatasets < ActiveRecord::Migration[7.1]
  def change
    add_column :lab_datasets, :user_id, :integer
  end
end
