class CreateSubjects < ActiveRecord::Migration[7.0]
  def change
    create_table :subjects do |t|
      t.string :label, null: false
      t.string :level, default: 'repo', null: false, comment: 'repo/community'
      t.string :status, default: 'pending', null: false, comment: 'pending/progress/complete'
      t.integer :count, default: 0, null: false
      t.datetime :status_updated_at
      t.timestamps
    end
    add_index :subjects, :label, unique: true
  end
end
