module SaltEdge
  module OB
    class TokenClientCredentialsService
      extend Callable
      include JWTAssertionConcern

      attr_reader :client, :software_credentials, :cert_credentials, :provider

      def initialize(
        provider: SaltEdge::Provider.ob,
        client: ClientFactory.oidc(provider),
        software_credentials: SoftwareCredentials.default,
        cert_credentials: CertCredentials.obseal
      )
        @client = client
        @software_credentials = software_credentials
        @cert_credentials = cert_credentials
        @provider = provider
      end

      def call
        api_result = client.post("tokens", body: {
          grant_type: "client_credentials",
          client_assertion_type: "urn:ietf:params:oauth:client-assertion-type:jwt-bearer",
          client_assertion: create_assertion
        })

        raise "Token response should be 200, received #{api_result.status}" if api_result.status != 200

        api_result.dig("access_token")
      end
    end
  end
end
