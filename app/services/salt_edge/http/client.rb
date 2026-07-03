# frozen_string_literal: true

require "json"

module SaltEdge
  module Http
    # Facade over uri builder + auth + sender: `get`/`post` build and send in one call.
    # `prepare` builds without sending — resolves the URL, JSON-encodes the body, and signs the
    # headers — returning a plain RequestData (useful for inspecting the signed request).
    class Client
      attr_reader :uri_builder, :auth, :sender

      def initialize(uri_builder:, auth: Strategies::TppSignatureAuth.new, sender: Sender.new)
        @uri_builder = uri_builder
        @auth = auth
        @sender = sender
      end

      def get(path, headers: {}, data: {})
        sender.call(prepare(:get, path, headers: headers, data: data))
      end

      def post(path, headers: {}, data: {})
        sender.call(prepare(:post, path, headers: headers, data: data))
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
          RequestData.new(
            method: :get,
            url: url,
            headers: auth.headers_for(headers),
            query: data,
            body: nil
          )
        when :post
          body = data.to_json
          RequestData.new(
            method: :post,
            url: url,
            headers: auth.headers_for(headers, body: body).merge("Content-Type" => "application/json"),
            query: {},
            body: body
          )
        else
          raise ArgumentError, "unsupported method: #{method.inspect}"
        end
      end
    end
  end
end
