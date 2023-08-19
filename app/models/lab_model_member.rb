# == Schema Information
#
# Table name: lab_model_members
#
#  id           :bigint           not null, primary key
#  user_id      :integer          not null
#  lab_model_id :integer          not null
#  permission   :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_lab_model_members_on_lab_model_id_and_user_id  (lab_model_id,user_id) UNIQUE
#
class LabModelMember < ApplicationRecord
  alias_attribute :joined_at, :created_at
  Read = 0b1
  Execute = 0b10
  Update = 0b100
  Destroy = 0b1000
  All = Read | Execute | Update | Destroy

  belongs_to :lab_model
  belongs_to :user

  validates :permission, presence: true

  delegate :name, to: :user
  delegate :avatar_url, to: :user

  def is_owner
    lab_model.user_id == user_id
  end

  def can_read
    permission & Read == Read
  end

  def can_update
    permission & Update == Update
  end

  def can_execute
    permission & Execute == Execute
  end

  def can_destory
    permission & Destroy == Destroy
  end

  def update_permission!(can_update: nil, can_execute: nil)
    current = permission
    current = change_update(current, can_update) if can_update != nil
    current = change_execute(current, can_execute) if can_execute != nil
    self.update!(permission: current)
  end

  private

  def change_read(current, bool)
    change_permission(current, Read, bool)
  end

  def change_update(current, bool)
    change_permission(current, Update, bool)
  end

  def change_execute(current, bool)
    change_permission(current, Execute, bool)
  end

  def change_permission(current, action, bool)
    bool ? (current | action) : (current & (current ^ action))
  end
end
