class AddFunctionalDescriptionToTpcSoftwareGraduations < ActiveRecord::Migration[7.1]
  def change
    add_column :tpc_software_graduations, :functional_description, :string, limit: 2000, null: true
  end
end
