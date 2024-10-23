class AddReferenceCountToLabModels < ActiveRecord::Migration[7.1]
  def change
    add_column :lab_models, :reference_count, :integer ,default: 0
  end
end
