class UserMailer < ApplicationMailer
  def email_verification
    @user = params[:user]
    @host = params[:host]
    @locale = params[:locale]
    I18n.locale = @locale
    @verify_url = "#{@host}/users/verify_email/#{@user.email_verification_token}"
    mail(to: @user.email, subject: I18n.t('user_mailer.email_verification.subject'))
  end
end
