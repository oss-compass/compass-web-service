class AddIsIncubationTpcSoftwareGraduationReports < ActiveRecord::Migration[7.1]
  def change
    add_column :tpc_software_graduation_reports, :is_incubation, :integer, null: true
  end
end
