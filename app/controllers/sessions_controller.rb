require 'securerandom'

class SessionsController < ApplicationController
  before_action :verify_guest!, except: :destroy

  layout 'auth'

  def new
  end

  def redirect
    Rails.application.routes.default_url_options[:host] = request.host
    uuid = SecureRandom.uuid

    create_response = ::SaltEdge::ConsentCreateService.call(redirect_url: sessions_create_url(uuid: uuid))

    show_response = ::SaltEdge::ConsentShowService.call(consent_id: create_response[:consent_id])

    Rails.cache.write("user:#{uuid}:consent_creation", { consent_id: create_response[:consent_id] })

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

  private

  def verify_guest!
    redirect_to dashboard_path if current_user.present?
  end
end
