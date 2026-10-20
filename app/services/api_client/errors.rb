# frozen_string_literal: true

module ApiClient
  # Api exceptions
  module Errors
    Error = Class.new(StandardError)

    class ResponseError < Error
      attr_reader :status, :code, :body

      def initialize(status:, code:, message:, body:)
        @status = status
        @code = code
        @body = body

        super(message)
      end
    end

    Unauthorized = Class.new(ResponseError) # 401
    Forbidden = Class.new(ResponseError) # 403
    NotFound = Class.new(ResponseError) # 404
    ClientError = Class.new(ResponseError) # other 4xx
    ServerError = Class.new(ResponseError) # 5xx
  end
end
