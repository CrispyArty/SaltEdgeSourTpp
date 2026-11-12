# frozen_string_literal: true

module SaltEdge
  module OB
    class TokenAuthorizationCodeEndpoint
      include Callable
      include JWTAssertionConcern

      param :code
      param :client, default: -> { ClientFactory.oidc }
      param :credentials, default: -> { Credentials.default }
      param :redirect_uri, default: -> { Rails.configuration.salt_edge[:ob_callback_url] }

      def call
        response = client.post("tokens", body: {
          grant_type: "authorization_code",
          code:,
          redirect_uri:,
          client_assertion:,
          client_assertion_type: "urn:ietf:params:oauth:client-assertion-type:jwt-bearer"
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
