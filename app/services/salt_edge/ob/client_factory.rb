# frozen_string_literal: true

module SaltEdge
  module OB
    class ClientFactory
      def self.global
        build(
          nil,
          uri_builder: UriBuilders.global(base_uri: config[:base_uri])
        )
      end

      def self.token
        build(
          nil,
          uri_builder: UriBuilders.token(base_uri: config[:base_uri], provider: "demo_bank_ob_uk")
        )
      end

      def self.build(auth, uri_builder:)
        ApiClient::Client.new(
          uri_builder: uri_builder,
          auth: auth,
          sender: ApiClient::Logging::Sender.new(
            inner: ApiClient::Sender.new,
            logger: ApiClient::Logging::ApiRequestLogger.new
          )
        )
      end

      def self.config
        Rails.configuration.salt_edge
      end
    end
  end
end
