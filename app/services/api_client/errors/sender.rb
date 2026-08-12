# frozen_string_literal: true

module ApiClient
  module Errors
    # Decorator that turns non-2xx responses into typed exceptions.
    # Wrap it around Logging::Sender so the response is logged before we raise.
    class Sender
      STATUS_ERRORS = {
        401 => Unauthorized,
        403 => Forbidden,
        404 => NotFound
      }.freeze

      FALLBACK_MESSAGE = "API request failed"

      def initialize(inner:, error_parser: Parsers::Raw.new)
        @inner = inner
        @error_parser = error_parser
      end

      def call(data)
        result = @inner.call(data)
        return result if result.success?

        details = @error_parser.parse(result)

        raise error_class_for(result.status).new(
          status: result.status,
          code: details.code,
          message: "[#{result.status}] #{details.message.presence || FALLBACK_MESSAGE}",
          body: result.body
        )
      end

      private

      def error_class_for(status)
        STATUS_ERRORS[status] || (status >= 500 ? ServerError : ClientError)
      end
    end
  end
end
