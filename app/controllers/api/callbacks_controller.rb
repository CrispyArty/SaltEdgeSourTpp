module Api
  class CallbacksController < ActionController::API
    # allow_browser versions: :modern

    def success
      Rails.logger.debug "-----request", request
      render json: { status: "OK" }
    end
  end
end
