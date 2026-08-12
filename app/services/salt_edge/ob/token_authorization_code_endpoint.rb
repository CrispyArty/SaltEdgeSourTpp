# frozen_string_literal: true

module SaltEdge
  module OB
    TokenAuthorizationCodeEndpoint = ::Data.define(:code, :client, :credentials) do
      extend Callable
      include JWTAssertionConcern

      def initialize(
        code:,
        client: ClientFactory.oidc,
        credentials: Credentials.default
      ) = super

      def call
        response = client.post("tokens", body: {
          grant_type: "authorization_code",
          code: code,
          redirect_uri: Rails.configuration.salt_edge[:ob_callback_url],
          client_assertion_type: "urn:ietf:params:oauth:client-assertion-type:jwt-bearer",
          client_assertion: create_assertion
        })

        raise "Token response should be 200, received #{response.status}" if response.status != 200

        Adapters::AccessToken.new(
          access_token: response["access_token"],
          refresh_token: response["refresh_token"],
          id_token: response["id_token"],
          scope: response["scope"]
        )
      end
    end
  end
end
