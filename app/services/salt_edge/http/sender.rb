# frozen_string_literal: true

require "excon"

module SaltEdge
  module Http
    # The only object that performs HTTP. Reads a fully-built RequestData and returns an ApiResult.
    class Sender
      ApiError = Class.new(StandardError)

      def call(data)
        response = Excon.send(
          data.method,
          data.url,
          headers: data.headers,
          query: data.query,
          body: data.body
        )

        raise ApiError if response.status >= 500

        ApiResult.new(status: response.status, headers: response.headers, body: response.body)
      end
    end
  end
end
