class ApplicationController < ActionController::Base
  include AuthenticationConcern
  before_action :verify_certificate!

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  def verify_certificate!
    render 'errors/not_setup', layout: 'auth', status: 500 if Rails.root.join("storage", "certificates", "client_signed_certificate.crt")
  end
end
