class AddOsMappingToDashboardMetricInfos < ActiveRecord::Migration[7.1]
  def change

    add_column :dashboard_metric_infos, :metric_index, :string
    add_column :dashboard_metric_infos, :mapping_settings, :string
    add_column :dashboard_metric_infos, :mapping_description, :string

  end
end
