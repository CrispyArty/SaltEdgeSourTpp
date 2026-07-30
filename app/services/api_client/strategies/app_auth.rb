# frozen_string_literal: true

module ApiClient
  module Strategies
    class AppAuth
      def initialize(app_id:, app_secret:)
        @app_id = app_id
        @app_secret = app_secret
      end

      def headers_for(headers, body: nil)
        headers.merge("App-Id" => @app_id, "App-Secret" => @app_secret)
      end
    end
  end
end
