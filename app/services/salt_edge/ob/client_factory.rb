# frozen_string_literal: true

module SaltEdge
  module OB
    class ClientFactory
      def self.base(provider = SaltEdge::Provider.ob)
        build(
          UriBuilders.provider(base_uri: config[:base_uri], provider: provider.code),
        )
      end

      def self.regular(provider = SaltEdge::Provider.ob)
        build(
          UriBuilders.provider(base_uri: config[:base_uri], provider: provider.code),
          auth: Strategies::ClientCredentialsAuth.new
        )
      end

      def self.oidc(provider = SaltEdge::Provider.ob)
        build(
          UriBuilders.oidc(base_uri: config[:base_uri], provider: provider.code)
        )
      end

      def self.build(uri_builder, auth: nil)
        ApiClient::Client.new(
          uri_builder: uri_builder,
          auth: auth,
          sender: ApiClient::Logging::Sender.new(
            inner: ApiClient::Sender.new,
            logger: ApiClient::Logging::ApiRequestLogger.new
          )
        )
      end

      private

      def self.config
        Rails.configuration.salt_edge
      end
    end
  end
end
