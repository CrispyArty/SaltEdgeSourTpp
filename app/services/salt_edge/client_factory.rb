module SaltEdge
  class ClientFactory
    def self.with_provider
      LoggingClientService.new(inner: ClientService.new(
        uri_builder: UriBuilders.provider(
          base_uri: config[:base_uri],
          provider: config[:provider_code]
        )
      ))
    end

    def self.global
      LoggingClientService.new(inner: ClientService.new(
        uri_builder: UriBuilders.global(base_uri: config[:base_uri])
      ))
    end

    def self.base
      LoggingClientService.new(inner: ClientService.new(
        uri_builder: UriBuilders.base(base_uri: config[:base_uri]),
        auth: AppAuth.new(
          app_id: config[:tpp_verifier][:app_id],
          app_secret: config[:tpp_verifier][:app_secret]
        )
      ))
    end

    private

    def self.config
      Rails.configuration.salt_edge
    end
  end
end
