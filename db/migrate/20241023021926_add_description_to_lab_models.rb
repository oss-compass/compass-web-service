class AddDescriptionToLabModels < ActiveRecord::Migration[7.1]
  def change
    add_column :lab_models, :description, :text

  end
end
