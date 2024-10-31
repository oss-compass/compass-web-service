class AddParentLabModelVersionIdToLabModelVersions < ActiveRecord::Migration[7.1]
  def change
    add_column :lab_model_versions, :parent_lab_model_version_id, :bigint
  end
end
