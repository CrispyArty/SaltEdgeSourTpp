module SaltEdge
  module OB
    class TokenClientCredentialsService < ApplicationService
      attr_reader :client, :software_credentials, :cert_credentials

      def initialize(
        client: ClientFactory.token,
        software_credentials: SoftwareCredentials.default,
        cert_credentials: CertCredentials.obseal
      )
        @client = client
        @software_credentials = software_credentials
        @cert_credentials = cert_credentials
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
