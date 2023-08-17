class CreateLabModelAlgorithms < ActiveRecord::Migration[7.0]
  def change
    create_table :lab_algorithms do |t|
      t.string :ident, null: false
      t.text :extra, null: true

      t.timestamps
    end
  end
end
