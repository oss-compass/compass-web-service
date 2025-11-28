class CreateFeedbacks < ActiveRecord::Migration[7.1]
  def change
    create_table :feedbacks do |t|
      t.string :module, null: false
      t.string :content, null: false
      t.string :page
      t.integer :user_id, null: false

      t.timestamps
    end
  end
end
