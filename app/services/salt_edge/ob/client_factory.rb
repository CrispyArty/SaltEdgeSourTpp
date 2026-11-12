# frozen_string_literal: true

module SaltEdge
  module OB
    class ClientFactory
      def self.base
        build(
          UriBuilders.base(base_uri: config[:base_uri])
        )
      end

      def self.authorized(token_provider:, provider:)
        build(
          UriBuilders.provider(base_uri: config[:base_uri], provider: provider.code),
          auth: Strategies::AccessTokenAuth.new(token_provider: token_provider)
        )
      end

      def self.client_token_auth(provider:)
        build(
          UriBuilders.provider(base_uri: config[:base_uri], provider: provider.code),
          auth: Strategies::ClientCredentialsAuth.new(provider: provider)
        )
      end

      def self.oidc(provider:)
        build(
          UriBuilders.oidc(base_uri: config[:base_uri], provider: provider.code),
          error_parser: ErrorParsers::Oidc.new
        )
      end

      def self.build(uri_builder, auth: nil, error_parser: ErrorParsers::OpenBanking.new)
        ApiClient::Client.new(
          uri_builder: uri_builder,
          auth: auth,
          sender: ApiClient::Errors::Sender.new(
            inner: ApiClient::Logging::Sender.new(
              inner: ApiClient::Sender.new,
              logger: ApiClient::Logging::ApiRequestLogger.new
            ),
            error_parser: error_parser
          )
        )
      end

      def self.config
        Rails.configuration.salt_edge
      end
    end
  end
end
