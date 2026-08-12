# frozen_string_literal: true

require "excon"

module ApiClient
  class Sender
    def call(data)
      response = Excon.send(
        data.method,
        data.url,
        headers: data.headers,
        query: data.query,
        body: data.body
      )

      ApiResult.new(status: response.status, headers: response.headers, body: response.body)
    end
  end
end
