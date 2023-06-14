class CreateShortenedLabels < ActiveRecord::Migration[7.0]
  def change
    create_table :shortened_labels do |t|
      t.string :label, null: false
      t.string :short_code, null: false
      t.string :level, null: false

      t.timestamps
    end

    add_index :shortened_labels, [:label, :level], unique: true
    add_index :shortened_labels, :short_code, unique: true
  end
end
