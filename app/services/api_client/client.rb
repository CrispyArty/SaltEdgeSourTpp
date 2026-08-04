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
      sender.call(prepare(:get, path, headers: headers, data: query))
    end

    def post(path, headers: {}, body: {})
      sender.call(prepare(:post, path, headers: headers, data: body))
    end

    def prepare(method, path, headers: {}, data: {})
      build_data(method, path, headers, data)
    end

    private

    def build_url(path)
      uri_builder.build(path)
    end

    def build_data(method, path, headers, data)
      url = build_url(path)

      case method
      when :get
        headers = auth&.headers_for(headers) || headers

        RequestData.new(
          method: :get,
          url: url,
          headers: headers,
          query: data,
          body: nil
        )
      when :post
        body = data.to_json

        headers = auth&.headers_for(headers, body: body) || headers

        RequestData.new(
          method: :post,
          url: url,
          headers: headers.merge("Content-Type" => "application/json"),
          query: {},
          body: body
        )
      else
        raise ArgumentError, "unsupported method: #{method.inspect}"
      end
    end
  end
end
