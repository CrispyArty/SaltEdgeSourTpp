module SaltEdge
  class ClientFactory
    def self.with_provider
      provider = Rails.configuration.salt_edge[:provider_code]

      ClientService.new(
        uri_builder: UriBuilders::Provider.new(provider: provider)
      )
    end

    def self.global
      ClientService.new(
        uri_builder: UriBuilders::Global.new
      )
    end
  end
end