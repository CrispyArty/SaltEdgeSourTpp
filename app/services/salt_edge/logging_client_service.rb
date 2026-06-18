# frozen_string_literal: true

module SaltEdge
  class LoggingClientService
    def initialize(inner:, logger: Logging::ApiRequestLogger.new)
      @inner = inner
      @logger = logger
    end

    def get(path, headers: {}, data: {})
      call_with_log(method: :get, path: path, headers: headers, body: data) do
        @inner.get(path, headers: headers, data: data)
      end
    end

    def post(path, headers: {}, data: {})
      call_with_log(method: :post, path: path, headers: headers, body: data) do
        @inner.post(path, headers: headers, data: data)
      end
    end

    private

    # def method_missing(method_name, *args, **kwargs)
    #   path = args.first
    #   call_with_log(method: method_name, path: path, **kwargs) do
    #     @inner.public_send(method_name, path, headers: kwargs[:headers], body: kwargs[:data])
    #   end
    # end

    def call_with_log(method:, path:, headers:, body: nil)
      started = current_time
      url = @inner.build_url(path)
      response = nil
      error = nil

      begin
        response = yield
        response
      rescue StandardError => e
        error = e
        raise
      ensure
        duration_ms = ((current_time - started) * 1000).round(2)
        payload = Logging::RequestLogBuilder.new(
          method: method,
          url: url,
          started_at: started,
          headers: headers,
          body: body,
          response: response,
          error: error,
          duration_ms: duration_ms
        ).build

        begin
          @logger.record(payload)
        rescue StandardError => e
          Rails.logger.error("[LoggingClientService] logging failed: #{e.class}: #{e.message}")
        end
      end
    end

    def current_time
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end
  end
end
