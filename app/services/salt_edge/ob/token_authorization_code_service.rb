module SaltEdge
  module OB
    class TokenAuthorizationCodeService < ApplicationService
      attr_reader :client, :software_credentials, :cert_credentials, :code

      def initialize(
        code:,
        client: ClientFactory.token,
        software_credentials: SoftwareCredentials.default,
        cert_credentials: CertCredentials.obseal
      )
        @code = code
        @client = client
        @software_credentials = software_credentials
        @cert_credentials = cert_credentials
      end

      def call
        redirect = "http://localhost:3000/api/callback/success" # same as in authorization link

        api_result = client.post("tokens", body: {
          grant_type: "authorization_code",
          code: code,
          redirect_uri: redirect,
          client_assertion_type: "urn:ietf:params:oauth:client-assertion-type:jwt-bearer",
          client_assertion: create_assertion
        })

        # raise "Token response should be 200, received #{api_result.status}" if api_result.status != 200

        api_result
      end

      private

      def create_assertion(uuid: SecureRandom.uuid)
        JWT.encode(
          {
            iss: software_credentials.app_id,
            sub: software_credentials.app_id,
            aud: "https://priora.banksalt.com/api/oidc/demo_bank_ob_v3_dot1_dot11_uk_sandbox/tokens",
            iat: Time.now.to_i,
            exp: Time.now.to_i + 300,
            jti: uuid
          },
          cert_credentials.private_key,
          "RS256", { kid: "1" }
        )
      end
    end
  end
end
