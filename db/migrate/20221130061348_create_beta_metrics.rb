class CreateBetaMetrics < ActiveRecord::Migration[7.0]
  def change
    create_table :beta_metrics do |t|
      t.string :dimensionality
      t.string :metric
      t.string :desc
      t.string :status
      t.string :workflow
      t.string :project
      t.string :op_index
      t.string :op_metric
      t.text :extra

      t.timestamps
    end
  end
end
