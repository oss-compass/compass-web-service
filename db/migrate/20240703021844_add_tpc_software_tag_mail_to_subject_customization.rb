class AddTpcSoftwareTagMailToSubjectCustomization < ActiveRecord::Migration[7.1]
  def change
    add_column :subject_customizations, :tpc_software_tag_mail, :string, limit: 500, null: true
  end
end
