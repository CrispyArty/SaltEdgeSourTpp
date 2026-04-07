require 'securerandom'

class SessionsController < ApplicationController
  before_action :verify_guest!, except: :destroy

  layout 'auth'

  CreateSessionError = Class.new(StandardError)
  CreateConsentError = Class.new(StandardError)

  rescue_from CreateConsentError, with: :render_session_error
  rescue_from CreateSessionError, with: :render_session_error

  def new
  end

  def redirect
    Rails.application.routes.default_url_options[:host] = request.host
    uuid = SecureRandom.uuid

    create_response = ::SaltEdge::ConsentCreateService.call(redirect_url: sessions_create_url(uuid: uuid))
    show_response = ::SaltEdge::ConsentShowService.call(consent_id: create_response[:consent_id])

    Rails.cache.write("user:#{uuid}:consent_creation", { consent_id: create_response[:consent_id] })
    raise CreateConsentError, "Redirect not found!" unless show_response[:sca_redirect_link].present?

    redirect_to show_response[:sca_redirect_link], allow_other_host: true

    # head :ok
  end

  def create
    user = Rails.cache.fetch("user:#{params[:uuid]}:consent_creation")

    raise CreateSessionError, "Missing saved consent" unless user.present?

    consent = SaltEdge::ConsentShowService.call(consent_id: user[:consent_id])

    raise CreateSessionError, "Consent status should be \"valid\", current: \"#{consent[:consent_status]}\"" unless consent[:consent_status] == 'valid'

    sign_in(user[:consent_id])

    Rails.cache.delete("user:#{params[:uuid]}:consent_creation")

    redirect_to dashboard_path
  end

  def destroy
    sign_out

    redirect_to sign_in_path
  end

  private

  def verify_guest!
    redirect_to dashboard_path if current_user.present?
  end

  def render_session_error(exception)
    @exception = exception

    render 'errors/session', layout: 'error', status: 422
  end
end
