class UserMailer < ApplicationMailer
  def email_verification
    @user = params[:user]
    @host = params[:host]
    @locale = params[:locale]
    I18n.locale = @locale
    @verify_url = "#{@host}/users/verify_email/#{@user.email_verification_token}"
    mail(to: @user.email, subject: I18n.t('user_mailer.email_verification.subject'))
  end

  def email_invitation
    @user = params[:user]
    @host = params[:host]
    @locale = params[:locale]
    @model = params[:model]
    @token = params[:token]
    @email = params[:email]
    I18n.locale = @locale
    accept_url = "#{@host}/users/accept_invitation/#{@token}"
    params_encoded = Addressable::URI.encode("?accept_url=#{accept_url}&invitee=#{@user.name}&model=#{@model.name_after_reviewed}")
    @confirm_url = "#{@host}/lab/model/invite/confirm#{params_encoded}"
    mail(to: @email, subject: I18n.t('user_mailer.email_invitation.subject'))
  end

  def email_tpc_software_application
    @title = params[:title]
    @body = params[:body]
    @user_name = params[:user_name]
    @user_html_url = params[:user_html_url]
    @issue_title = params[:issue_title]
    @issue_html_url = params[:issue_html_url]
    @email = params[:email]
    @locale = 'zh-CN'.to_sym
    I18n.locale = @locale
    if params[:type] == 0
      mail(to: @email, subject: I18n.t('user_mailer.email_tpc_software_application.subject_application'))
    elsif params[:type] == 1
      mail(to: @email, subject: I18n.t('user_mailer.email_tpc_software_application.subject_review'))
    end

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
    @locale = params[:user].language
    @user = params[:user]
    @subject_name = params[:subject_name]
    @subject_url = params[:subject_url]
    @subscription_url = params[:subscription_url]
    @explore_url = params[:explore_url]
    @about_url = params[:about_url]
  end
end
