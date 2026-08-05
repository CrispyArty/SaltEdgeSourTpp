module SaltEdge
  module OB
    class TokenAuthorizationCodeService
      extend Callable
      attr_reader :client, :software_credentials, :cert_credentials, :code
      include JWTAssertionConcern

      def initialize(
        code:,
        client: ClientFactory.oidc,
        software_credentials: SoftwareCredentials.default,
        cert_credentials: CertCredentials.obseal
      )
        @code = code
        @client = client
        @software_credentials = software_credentials
        @cert_credentials = cert_credentials
      end

      def call
        client.post("tokens", body: {
          grant_type: "authorization_code",
          code: code,
          redirect_uri: Rails.configuration.salt_edge[:ob_callback_url],
          client_assertion_type: "urn:ietf:params:oauth:client-assertion-type:jwt-bearer",
          client_assertion: create_assertion
        })
      end
    end
  end
end
