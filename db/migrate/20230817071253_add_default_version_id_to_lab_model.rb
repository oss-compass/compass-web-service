class AddDefaultVersionIdToLabModel < ActiveRecord::Migration[7.0]
  def change
    add_column :lab_models, :default_version_id, :integer
  end
end
