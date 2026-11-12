module Api
  module BG
    class CallbacksController < ActionController::API
      def success
        Rails.logger.debug "-----request", request
        render json: { status: "OK" }
      end
    end
  end
end

