class CreateLabMetrics < ActiveRecord::Migration[7.0]
  def change
    create_table :lab_metrics do |t|
      t.string :name, null: false
      t.string :ident, null: false
      t.string :category, null: false
      t.string :from
      t.float :default_weight
      t.float :default_threshold

      t.timestamps
    end
  end
end
