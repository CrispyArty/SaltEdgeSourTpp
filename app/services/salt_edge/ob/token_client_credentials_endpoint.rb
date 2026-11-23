# frozen_string_literal: true

module SaltEdge
  module OB
    class TokenClientCredentialsEndpoint
      include Callable
      include JWTAssertionConcern

      param :provider
      param :credentials
      param :client, default: -> { ClientFactory.oidc(provider:) }

      def call
        api_result = client.post("tokens", body: {
          grant_type: "client_credentials",
          client_assertion_type: "urn:ietf:params:oauth:client-assertion-type:jwt-bearer",
          client_assertion: create_assertion
        })

        api_result.dig("access_token")
      end
    end
  end
end
