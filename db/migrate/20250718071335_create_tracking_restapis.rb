class CreateTrackingRestapis < ActiveRecord::Migration[7.1]
  def change
    create_table :tracking_restapis do |t|
      t.integer :user_id
      t.string :api_path, null: false
      t.string :domain, null: false
      t.string :ip

      t.timestamps
    end
  end
end
