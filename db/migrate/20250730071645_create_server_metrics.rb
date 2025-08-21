class CreateServerMetrics < ActiveRecord::Migration[7.1]
  def change
    create_table :server_metrics do |t|
      t.string  :server_id, null: false
      t.float   :cpu_percent
      t.float   :memory_percent
      t.float   :disk_percent
      t.float   :disk_io_read
      t.float   :disk_io_write
      t.float   :net_io_recv
      t.float   :net_io_sent
      t.timestamps
    end
  end
end
