# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, 'reserved anonymous email domain' do
  it 'rejects regular signup with a synthesized anonymous address' do
    user = User.new(email: 'Gitee_123@user.anonymous.oss-compass.org', password: 'a-valid-password')

    user.validate

    expect(user.errors[:email]).to be_present
  end

  it 'still allows internally created anonymous OAuth users' do
    user = User.new(email: 'gitee_123@user.anonymous.oss-compass.org', password: 'a-valid-password', anonymous: true)

    user.validate

    expect(user.errors[:email].join).not_to match(/reserved/i)
  end

  it 'does not affect normal email signups' do
    user = User.new(email: 'someone@example.com', password: 'a-valid-password')

    user.validate

    expect(user.errors[:email].join).not_to match(/reserved/i)
  end
end
