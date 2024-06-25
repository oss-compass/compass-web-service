class CreateSubjectLicenses < ActiveRecord::Migration[7.1]
  def change
    create_table :subject_licenses do |t|
      t.string :license, null: true
      t.timestamps
    end
  end
end
