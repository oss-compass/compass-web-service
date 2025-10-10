class AddUpstreamCollaborationStrategyRawToTpcSoftwareReportMetricRaws < ActiveRecord::Migration[7.1]
  def change

      add_column :tpc_software_report_metric_raws, :upstream_collaboration_strategy_raw, :string

  end
end
