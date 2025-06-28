class CreateTrackingEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :tracking_events do |t|
      t.string :event_type, null: false
      t.bigint :timestamp, null: false
      t.integer :user_id
      t.string :page_path, null: false
      t.string :module_id
      t.string :referrer

      t.string :device_user_agent
      t.string :device_language
      t.string :device_timezone

      t.string :data, null: false

      t.string :ip

      t.timestamps
    end
  end
end
