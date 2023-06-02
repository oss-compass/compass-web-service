class UserMailer < ApplicationMailer
  def email_verification
    @user = params[:user]
    @host = params[:host]
    @locale = params[:locale]
    I18n.locale = @locale
    @verify_url = "#{@host}/users/verify_email/#{@user.email_verification_token}"
    mail(to: @user.email, subject: I18n.t('user_mailer.email_verification.subject'))
  end

  def subscription_update
    submission_params
    mail(to: @user.email, subject: "#{I18n.t('notification.email.project_subscription_update', locale: @user.language)} - #{@subject_name}")
  end

  def submission
    submission_params
    mail(to: @user.email, subject: I18n.t('notification.email.project_subscription', locale: @user.language))
  end

  def subscription_create
    submission_params
    mail(to: @user.email, subject: I18n.t('notification.email.project_subscription', locale: @user.language))
  end

  def subscription_delete
    submission_params
    mail(to: @user.email, subject: I18n.t('notification.email.project_unsubscription', locale: @user.language))
  end

  def submission_params
    @locale = user.language
    @user = params[:user]
    @subject_name = params[:subject_name]
    @subject_url = params[:subject_url]
    @subscription_url = params[:subscription_url]
    @explore_url = params[:explore_url]
    @about_url = params[:about_url]
  end
end
