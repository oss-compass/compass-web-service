class AddIsScoreToLabModelVersions < ActiveRecord::Migration[7.1]
  def change
    add_column :lab_model_versions, :is_score, :boolean ,default:false
  end
end
