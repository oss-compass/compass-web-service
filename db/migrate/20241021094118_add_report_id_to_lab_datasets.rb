class AddReportIdToLabDatasets < ActiveRecord::Migration[7.1]
  def change
    add_column :lab_datasets, :lab_model_report_id, :bigint
  end
end
