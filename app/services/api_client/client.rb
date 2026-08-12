# frozen_string_literal: true

require "json"

module ApiClient
  # Facade
  class Client
    extend Forwardable

    def_delegator :sender, :call, :execute

    attr_reader :uri_builder, :auth, :sender

    def initialize(uri_builder:, auth: nil, sender: Sender.new)
      @uri_builder = uri_builder
      @auth = auth
      @sender = sender
    end

    def get(path, headers: {}, query: {})
      sender.call(prepare(:get, path, headers: headers, query: query))
    end

    def post(path, headers: {}, body: {})
      sender.call(prepare(:post, path, headers: headers, body: body))
    end

    def prepare(method, path, headers: {}, query: {}, body: nil)
      build_data(method, path, headers, query, body)
    end

    private

    def build_data(method, path, headers, query, body = nil)
      url = uri_builder.build(path)

      headers = auth&.headers_for(headers, body) || headers

      if body.is_a?(Hash)
        headers = headers.merge("Content-Type" => "application/json")
        body = body.to_json
      end

      RequestData.new(
        method: method,
        url: url,
        headers: headers,
        query: query,
        body: body
      )
    end
  end
end
