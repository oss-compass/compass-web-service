class CreateCollections < ActiveRecord::Migration[7.0]
  def change
    create_table :collections do |t|
      t.string :title, null: false
      t.text :desc

      t.timestamps
    end

    add_index :collections, :title
  end
end
