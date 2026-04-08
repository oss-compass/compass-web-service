# == Schema Information
#
# Table name: dashboard_members
#
#  id            :bigint           not null, primary key
#  dashboard_id  :bigint           not null
#  user_id       :bigint           not null
#  role          :integer          default("viewer"), not null
#  status        :integer          default("active"), not null
#  invited_by_id :bigint
#  joined_at     :datetime
#  remark        :text(65535)
#
# Indexes
#
#  index_dashboard_members_on_dashboard_id   (dashboard_id)
#  index_dashboard_members_on_invited_by_id  (invited_by_id)
#  index_dashboard_members_on_user_id        (user_id)
#
class DashboardMember < ApplicationRecord
  belongs_to :dashboard
  belongs_to :user
  belongs_to :invited_by, class_name: 'User', optional: true

  enum role: {
    viewer: 0,   # 查看者：仅查看
    editor: 1,   # 编辑者：查看 + 编辑配置
    admin: 2     # 管理员：查看 + 编辑 + 管理成员 + 删除看板
  }

  enum status: {
    active: 0,   # 正常
    disabled: 1  # 禁用
  }

  validates :user_id, uniqueness: { scope: :dashboard_id, message: '该用户已是看板成员' }

  # 权限检查
  def can_edit? = editor? || admin?
  def can_manage_members? = admin?
  def can_delete_dashboard? = admin?
end
