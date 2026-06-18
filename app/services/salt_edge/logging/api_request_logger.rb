# frozen_string_literal: true

module SaltEdge
  module Logging
    class ApiRequestLogger
      def initialize(sink: ApiRequest)
        @sink = sink
      end

      def record(payload)
        @sink.create!(payload)
      end
    end
  end
end
