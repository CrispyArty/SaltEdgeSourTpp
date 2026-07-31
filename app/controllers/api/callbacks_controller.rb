module Api
  class CallbacksController < ActionController::API
    # allow_browser versions: :modern

    def success
      p "-----request", request
      render json: { status: "OK" }
    end
  end
end
