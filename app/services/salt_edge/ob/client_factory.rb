# frozen_string_literal: true

module SaltEdge
  module OB
    class ClientFactory
      def self.base
        build(
          UriBuilders.global(base_uri: config[:base_uri], provider: provider),
        )
      end

      def self.global
        build(
          UriBuilders.global(base_uri: config[:base_uri], provider: provider),
          auth: Strategies::ClientCredentialsAuth.new
        )
      end

      def self.token
        build(
          UriBuilders.token(base_uri: config[:base_uri], provider: provider)
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

      def self.provider
        "demo_bank_ob_v3_dot1_dot11_uk_sandbox"
      end
    end
  end
end
