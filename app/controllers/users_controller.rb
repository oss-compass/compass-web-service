class UsersController < ApplicationController
  def verify_email
    token = params[:token]
    user = User.find_by(email_verification_token: token)
    if user.present? && user.verify_email(token)
      redirect_to url_for('/pages/auth/email/verify/success')
    else
      redirect_to url_for('/pages/auth/email/verify/failed')
    end
  end
end
