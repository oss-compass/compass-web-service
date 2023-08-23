class UsersController < ApplicationController
  def verify_email
    token = params[:token]
    user = User.find_by(email_verification_token: token)
    if user.present? && user.verify_email(token)
      redirect_to url_for('/auth/email/verify/success')
    else
      redirect_to url_for('/auth/email/verify/failed')
    end
  end

  def accept_invitation
    redirect_to url_for('/auth/signin') unless current_user.present?
    token = params[:token]
    invitation = LabModelInvitation.find_by(token: token)
    error = nil
    error = I18n.t('lab_models.invalid_invitation') unless invitation.present?
    ok, error = invitation.verify_and_finish!(current_user, token) if error.blank?

    if error.present?
      uri = Addressable::URI.parse('/lab/model/my')
      uri.query_values = uri.query_values.to_h.merge({ error: error, ts: Time.now.to_i })
      redirect_to url_for(uri.to_s)
    else
      redirect_to url_for("/lab/model/#{invitation.lab_model.id}/user")
    end
  end
end
