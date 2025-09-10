class CreateMqMetrics < ActiveRecord::Migration[7.1]
  def change
    create_table :mq_metrics do |t|
      t.integer :total
      t.integer :ready
      t.integer :unacknowledged
      t.integer :consumers

      t.string :queue_name
      t.string :queue_type
      t.string :belong_to

      t.timestamps
    end
  end
end
