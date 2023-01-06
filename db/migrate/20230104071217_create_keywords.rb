class CreateKeywords < ActiveRecord::Migration[7.0]
  def change
    create_table :keywords do |t|
      t.string :title, null: false
      t.text :desc

      t.timestamps
    end

    add_index :keywords, :title
  end
end
