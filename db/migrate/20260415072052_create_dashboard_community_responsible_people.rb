class CreateDashboardCommunityResponsiblePeople < ActiveRecord::Migration[7.1]
  def change
    create_table :dashboard_community_responsible_people do |t|
      t.references :dashboard, foreign_key: true, comment: '关联看板'
      t.references :user, foreign_key: true, comment: '责任人用户'
      t.string :label, comment: '仓库地址'
      t.timestamps
    end
  end
end
