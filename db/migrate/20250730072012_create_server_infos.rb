class CreateServerInfos < ActiveRecord::Migration[7.1]
  def change
    create_table :server_infos do |t|
      t.string :server_id, null: false
      t.string :hostname
      t.string :ip_address
      t.string :location
      t.string :status
      t.string :use_for
      t.string :belong_to

      t.string :cpu_info
      t.string :memory_info
      t.string :storage_info
      t.string :net_info
      t.string :system_info
      t.string :architecture_info

      t.string :description

      t.timestamps
    end
  end
end
