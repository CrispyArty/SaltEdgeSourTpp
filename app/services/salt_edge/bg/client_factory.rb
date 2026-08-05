# frozen_string_literal: true

module SaltEdge
  module BG
    class ClientFactory
      def self.with_provider(provider = SaltEdge::Provider.bg)
        build(
          Strategies::TppSignatureAuth.new,
          uri_builder: UriBuilders.provider(
            base_uri: config[:base_uri],
            provider: provider.code
          )
        )
      end

      def self.global
        build(
          Strategies::TppSignatureAuth.new,
          uri_builder: UriBuilders.global(base_uri: config[:base_uri])
        )
      end

      def self.build(auth, uri_builder:)
        ApiClient::Client.new(
          uri_builder: uri_builder,
          auth: auth,
          sender: ApiClient::Logging::Sender.new(inner: ApiClient::Sender.new, logger: ApiClient::Logging::ApiRequestLogger.new)
        )
      end

      def self.config
        Rails.configuration.salt_edge
      end
    end
  end
end
