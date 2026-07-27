# frozen_string_literal: true

module SaltEdge
  class ClientFactory
    def self.with_provider
      build(
        Http::Strategies::TppSignatureAuth.new,
        uri_builder: Http::UriBuilders.provider(
          base_uri: config[:base_uri],
          provider: config[:provider_code]
        )
      )
    end

    def self.global
      build(
        Http::Strategies::TppSignatureAuth.new,
        uri_builder: Http::UriBuilders.global(base_uri: config[:base_uri])
      )
    end

    def self.base
      build(
        Http::Strategies::AppAuth.new(
          app_id: config[:tpp_verifier][:app_id],
          app_secret: config[:tpp_verifier][:app_secret]
        ),
        uri_builder: Http::UriBuilders.base(base_uri: config[:base_uri])
      )
    end

    def self.build(auth, uri_builder:)
      Http::Client.new(
        uri_builder: uri_builder,
        auth: auth,
        sender: Logging::Sender.new(inner: Http::Sender.new, logger: Logging::ApiRequestLogger.new)
      )
    end

    def self.config
      Rails.configuration.salt_edge
    end
  end
end
