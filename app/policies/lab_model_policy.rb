# frozen_string_literal: true

class LabModelPolicy < ApplicationPolicy
  attr_reader :user, :lab_model, :member

  def initialize(user, lab_model)
    @user = user
    @lab_model = lab_model
    @member = lab_model&.members&.find_by(user: user)
  end

  def create_version?
    member ? allow?(LabModelMember::Update) : false
  end

  def view?
    lab_model.is_public ? true : member ? allow?(LabModelMember::Read) : false
  end

  def read?
    member ? allow?(LabModelMember::Read) : false
  end

  def invite?
    member ? allow?(LabModelMember::Update) : false
  end

  def cancel?
    member ? allow?(LabModelMember::Update) : false
  end

  def update?
    member ? allow?(LabModelMember::Update) : false
  end

  def execute?
    member ? allow?(LabModelMember::Execute) : false
  end

  def destroy?
    member ? allow?(LabModelMember::Destroy) : false
  end

  private

  def allow?(action)
    member.permission & action == action
  end
end
