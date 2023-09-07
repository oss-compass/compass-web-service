class ChangeLabelCollationOfShortenedLabel < ActiveRecord::Migration[7.0]
  def up
    change_column :shortened_labels, :label, :string, limit: 255, collation: 'utf8mb4_bin'
  end

  def down
    change_column :shortened_labels, :label, :string, limit: 255, collation: 'utf8mb4_general_ci'
  end
end
