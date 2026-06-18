# frozen_string_literal: true

module SaltEdge
  module Logging
    class RequestLogBuilder
      def initialize(method:, url:, started_at:, headers:, body:, response:, error:, duration_ms:)
        @method = method
        @url = url
        @started_at = started_at
        @headers = headers
        @body = body
        @response = response
        @error = error
        @duration_ms = duration_ms
      end

      def build
        {
          method: @method.to_s.upcase,
          url: @url,
          status: extract_status,
          duration_ms: @duration_ms,
          request_headers: @headers,
          request_body: parse_json(@body),
          response_headers: extract_response_headers,
          response_body: extract_response_body,
          error_class: @error&.class&.name,
          error_message: @error&.message
        }
      end

      private

      def extract_status
        @response&.status
      end

      def extract_response_headers
        @response&.headers
      end

      def extract_response_body
        raw = @response&.body
        return nil if raw.nil?

        parse_json(raw) || raw
      end

      def parse_json(raw)
        return nil if raw.nil? || raw.empty?

        JSON.parse(raw)
      rescue JSON::ParserError
        nil
      end
    end
  end
end
