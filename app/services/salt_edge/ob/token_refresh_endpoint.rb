# frozen_string_literal: true

module SaltEdge
  module OB
    TokenRefreshEndpoint = ::Data.define(:refresh_token, :client, :credentials) do
      extend Callable
      include JWTAssertionConcern

      def initialize(
        refresh_token:,
        client: ClientFactory.oidc,
        credentials: Credentials.default
      ) = super

      def call
        response = client.post("tokens", body: {
          grant_type: "refresh_token",
          scope: "accounts openid",
          refresh_token: refresh_token,
          redirect_uri: Rails.configuration.salt_edge[:ob_callback_url],
          client_assertion_type: "urn:ietf:params:oauth:client-assertion-type:jwt-bearer",
          client_assertion: create_assertion
        })

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
