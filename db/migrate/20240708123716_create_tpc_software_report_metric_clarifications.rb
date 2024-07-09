class CreateTpcSoftwareReportMetricClarifications < ActiveRecord::Migration[7.1]
  def change
    create_table :tpc_software_report_metric_clarifications do |t|

      t.integer :tpc_software_report_metric_id, null: false
      t.integer :user_id, null: false
      t.integer :subject_id, null: false
      t.string :metric_name, null: false
      t.string :content, null: false
      t.timestamps
    end
  end
end
