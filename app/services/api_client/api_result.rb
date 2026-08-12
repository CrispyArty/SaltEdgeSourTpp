# frozen_string_literal: true

module ApiClient
  class ApiResult
    attr_reader :status, :headers, :body

    def initialize(status:, headers:, body:)
      @status = status
      @headers = headers
      @body = body
    end

    delegate :[], to: :parsed

    def dig(*keys)
      parsed.dig(*keys)
    end

    delegate :with_indifferent_access, to: :parsed

    def success?
      status.between?(200, 299)
    end

    # Error bodies are not always JSON — an OB 401 carries no body at all.
    def parsed_or_empty
      parsed
    rescue JSON::ParserError, TypeError
      {}
    end

    private

    def parsed
      @parsed ||= JSON.parse(@body)
    end
  end
end
