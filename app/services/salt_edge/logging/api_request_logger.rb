# frozen_string_literal: true

module SaltEdge
  module Logging
    class ApiRequestLogger
      def initialize(sink: ApiRequest)
        @sink = sink
      end

      def start(payload)
        @sink.create!(payload.merge(pending: true))
      end

      def complete(record, payload)
        record&.update!(payload.merge(pending: false))
      end
    end
  end
end
