class ChangeAdaptationMethodNullInTpcSoftwareSelections < ActiveRecord::Migration[7.1]
  def change
    change_column_null :tpc_software_selections, :adaptation_method, true
  end
end
