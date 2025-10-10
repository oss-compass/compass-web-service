class AddUpstreamCollaborationStrategyToTpcSoftwareReportMetrics < ActiveRecord::Migration[7.1]
  def change
    unless column_exists?(:tpc_software_report_metrics, :upstream_collaboration_strategy)
      add_column :tpc_software_report_metrics, :upstream_collaboration_strategy, :bigint
    end

    unless column_exists?(:tpc_software_report_metrics, :upstream_collaboration_strategy_detail)
      add_column :tpc_software_report_metrics, :upstream_collaboration_strategy_detail, :string
    end
  end
end
