class AddDimensionToDashboardModelInfos < ActiveRecord::Migration[7.1]
  def change
    add_column :dashboard_model_infos, :dimension, :string
  end
end
