# frozen_string_literal: true

module SaltEdge
  module BG
    class ClientFactory
      def self.with_provider
        build(
          Strategies::TppSignatureAuth.new,
          uri_builder: ApiClient::UriBuilders.provider(
            base_uri: config[:base_uri],
            provider: config[:provider_code]
          )
        )
      end

      def self.global
        build(
          Strategies::TppSignatureAuth.new,
          uri_builder: ApiClient::UriBuilders.global(base_uri: config[:base_uri])
        )
      end

      def self.base
        build(
          Strategies::AppAuth.new(
            app_id: config[:tpp_verifier][:app_id],
            app_secret: config[:tpp_verifier][:app_secret]
          ),
          uri_builder: ApiClient::UriBuilders.base(base_uri: config[:base_uri])
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
