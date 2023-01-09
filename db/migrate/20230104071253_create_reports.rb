class CreateReports < ActiveRecord::Migration[7.0]
  def change
    create_table :reports do |t|
      t.text :content
      t.string :lang
      t.string :associated_id
      t.string :associated_type
      t.text :extra
      t.timestamps
    end
  end
end
