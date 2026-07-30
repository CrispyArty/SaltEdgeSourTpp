# frozen_string_literal: true

module ApiClient
  module Logging
    class Sender
      def initialize(inner:, logger: ApiRequestLogger.new)
        @inner = inner
        @logger = logger
      end

      def call(data)
        record = guard { @logger.start(RequestLogBuilder.request_payload(data)) }
        started = current_time
        response = nil
        error = nil

        begin
          response = @inner.call(data)
          response
        rescue StandardError => e
          error = e
          raise
        ensure
          duration_ms = ((current_time - started) * 1000).round(2)
          guard do
            @logger.complete(
              record,
              RequestLogBuilder.response_payload(response: response, error: error, duration_ms: duration_ms)
            )
          end
        end
      end

      private

      # Logging must never break the API call.
      def guard
        yield
      rescue StandardError => e
        Rails.logger.error("[ApiClient::LoggingSender] logging failed: #{e.class}: #{e.message}")
        nil
      end

      def current_time
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end
    end
  end
end
