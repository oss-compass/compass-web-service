class AddCollectAtAndCompleteAtToSubjects < ActiveRecord::Migration[7.0]
  def change
    add_column :subjects, :collect_at, :datetime
    add_column :subjects, :complete_at, :datetime
  end
end
