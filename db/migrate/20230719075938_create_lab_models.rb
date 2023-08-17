class CreateLabModels < ActiveRecord::Migration[7.0]
  def change
    create_table :lab_models do |t|
      t.string :name, null: false
      t.integer :user_id, null: false
      t.integer :dimension, null: false
      t.boolean :is_general, null: false
      t.boolean :is_public, null: false

      t.timestamps
    end
  end
end
