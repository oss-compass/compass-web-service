class AddModelTypeToLabModels < ActiveRecord::Migration[7.1]
  def change
    add_column :lab_models, :model_type, :bigint
  end
end
