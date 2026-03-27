class AddSecondDimensionToDashboardModelInfos < ActiveRecord::Migration[7.1]
  def change
    add_column :dashboard_model_infos, :second_dimension, :string
  end
end
