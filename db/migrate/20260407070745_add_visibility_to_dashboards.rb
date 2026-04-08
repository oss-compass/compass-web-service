class AddVisibilityToDashboards < ActiveRecord::Migration[7.1]
  def change
    add_column :dashboards, :visibility, :integer, default: 0
  end
end
