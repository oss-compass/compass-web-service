class CreateTpcAutoCreateOrgs < ActiveRecord::Migration[7.1]
  def change
    create_table :tpc_auto_create_orgs do |t|
      t.string :org_url, null: false
      t.string :name
      t.boolean :enabled, default: true
      t.timestamps
    end
  end
end
