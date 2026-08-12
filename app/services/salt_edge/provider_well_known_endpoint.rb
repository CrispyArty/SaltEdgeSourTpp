module SaltEdge
  class ProviderWellKnownEndpoint
    extend Callable

    attr_reader :client, :provider_code

    config = Rails.configuration.salt_edge

    CLIENT = ApiClient::Client.new(
      uri_builder: ApiClient::UriBuilders::Template.new(pattern: "#{config[:base_uri]}/%{endpoint}"),
      sender: ApiClient::Sender.new
    )

    def initialize(provider_code:, client: CLIENT)
      @client = client
      @provider_code = provider_code
    end

    def call
      data = client.get("/.well-known/openid-configuration/#{provider_code}")

      {
        authorization_endpoint: data["authorization_endpoint"],
        scopes_supported: data["scopes_supported"]
      }
    end
  end
end
