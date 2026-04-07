require 'securerandom'

class SessionsController < ApplicationController
  layout 'auth'

  def new
  end

  def redirect
    Rails.application.routes.default_url_options[:host] = request.host
    uuid = SecureRandom.uuid

    # Create Consent for AIS flow
    p '---sessions_create_url', sessions_create_url(uuid: uuid)
    create_response = ::SaltEdge::ConsentCreateService.call(redirect_url: sessions_create_url(uuid: uuid))
    p '------------create_response', create_response

    show_response = ::SaltEdge::ConsentShowService.call(consent_id: create_response[:consent_id])

    Rails.cache.write("user:#{uuid}:consent_creation", { consent_id: create_response[:consent_id] })

    p '-----------show_response', show_response
    # TODO: Handle exception
    raise "Redirect not found!" unless show_response[:sca_redirect_link].present?

    redirect_to show_response[:sca_redirect_link], allow_other_host: true

    # head :ok
  end

  def create
    user = Rails.cache.fetch("user:#{params[:uuid]}:consent_creation")

    raise ActionController::BadRequest, "Missing saved consent" unless user.present?

    sign_in(user[:consent_id])

    redirect_to dashboard_path
  end

  def destroy
    sign_out

    redirect_to sign_in_path
  end
end
