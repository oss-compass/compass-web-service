class CreateStarProjectParticipants < ActiveRecord::Migration[7.1]
  def change
    create_table :star_project_participants do |t|
      t.integer :star_project_id, null: false
      t.string :product_line, comment: "产品线"
      t.string :participant_account_name, comment: "参与人的代码托管平台账号名称"
      t.string :participant_company_id, comment: "参与人的公司ID"
      t.string :related_email, comment: "关联邮箱"
      t.timestamps
    end
  end
end
