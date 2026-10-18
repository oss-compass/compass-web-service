require 'rails_helper'

RSpec.describe GraphqlController, type: :controller do
  describe '#sign_out' do
    it 'does not write the raw auth token to the application log' do
      user = instance_double(User)
      warden = double('warden')
      decoder = double('token decoder')
      cookies = double('cookies')

      allow(Devise::Mapping).to receive(:find_scope!).with(user).and_return(:user)
      allow(warden).to receive(:logout).with(:user)
      allow(controller).to receive(:warden).and_return(warden)
      allow(controller).to receive(:request).and_return(double('request', cookies: { 'auth.token' => 'secret-token' }))
      allow(controller).to receive(:cookies).and_return(cookies)
      allow(cookies).to receive(:delete).with('auth.token')
      allow(Warden::JWTAuth::TokenDecoder).to receive(:new).and_return(decoder)
      allow(decoder).to receive(:call).with('secret-token').and_return({})
      allow(User).to receive(:revoke_jwt)

      expect(Rails.logger).not_to receive(:info).with('secret-token')

      controller.send(:sign_out, user)
    end
  end
end
