# frozen_string_literal: true

module SaltEdge
  module Logging
    # Two-phase persistence into ApiRequest: `start` creates a pending row before the request
    # is sent, `complete` fills in the outcome (response or error) and clears the pending flag.
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
