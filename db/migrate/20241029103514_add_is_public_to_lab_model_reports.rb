class AddIsPublicToLabModelReports < ActiveRecord::Migration[7.1]
  def change
    add_column :lab_model_reports, :is_public, :boolean, default: false
  end
end
