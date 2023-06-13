class CreateShortenedLabels < ActiveRecord::Migration[7.0]
  def change
    create_table :shortened_labels do |t|
      t.string :label
      t.string :short_code
      t.string :level

      t.timestamps
    end

    add_index :shortened_labels, [:label, :level], unique: true
    add_index :shortened_labels, :short_code, unique: true
  end
end
