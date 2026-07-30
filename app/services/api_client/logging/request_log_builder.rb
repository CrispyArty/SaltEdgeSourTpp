# frozen_string_literal: true

module ApiClient
  module Logging
    class RequestLogBuilder
      class << self
        def request_payload(data)
          {
            method: data.method.to_s.upcase,
            url: data.url,
            request_headers: data.headers,
            request_body: parse_json(data.body)
          }
        end

        def response_payload(response:, error:, duration_ms:)
          {
            status_code: response&.status,
            duration_ms: duration_ms,
            response_headers: response&.headers,
            response_body: response&.body,
            error_class: error&.class&.name,
            error_message: error&.message
          }
        end

        private

        def parse_json(raw)
          return nil if raw.nil? || raw.empty?

          JSON.parse(raw)
        rescue JSON::ParserError
          nil
        end
      end
    end
  end
end
