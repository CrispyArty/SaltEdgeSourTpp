# frozen_string_literal: true

module SaltEdge
  class ApiResult
    attr_reader :status, :headers, :body

    def initialize(status:, headers:, body:)
      @status  = status
      @headers = headers
      @body    = body
    end

    def [](key)
      parsed[key]
    end

    def dig(*keys)
      parsed.dig(*keys)
    end

    def with_indifferent_access
      parsed.with_indifferent_access
    end

    private

    def parsed
      @parsed ||= JSON.parse(@body)
    end
  end
end
