module AuthenticationConcern
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :user_signed_in?
  end

  def current_user
    Current.user ||= { consent_id: session[:consent_id] } if session[:user_id]
  end

  def user_signed_in?
    current_user.present?
  end

  def sign_in(consent_id)
    Current.user = { consent_id: consent_id }
    session[:consent_id] = consent_id
  end

  def sign_out
    Current.user = nil
    reset_session
    # session.delete(:consent_id)
  end
end