class AddParentModelIdToLabModels < ActiveRecord::Migration[7.1]
  def change
    add_column :lab_models, :parent_model_id, :bigint
  end
end
