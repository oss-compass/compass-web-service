class AddLicenseToTpcSoftwareGraduationReports < ActiveRecord::Migration[7.1]
  def change
    add_column :tpc_software_graduation_reports, :license, :string, null: true
    add_column :tpc_software_graduation_reports, :code_count, :integer, null: true
  end
end
