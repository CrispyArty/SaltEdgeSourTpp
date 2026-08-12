# frozen_string_literal: true

module SaltEdge
  module OB
    TokenClientCredentialsEndpoint = ::Data.define(:provider, :client, :credentials) do
      extend Callable
      include JWTAssertionConcern

      def initialize(
        provider: SaltEdge::Provider.ob,
        client: ClientFactory.oidc(provider),
        credentials: Credentials.default
      ) = super

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
