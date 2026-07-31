# frozen_string_literal: true

module SaltEdge
  module OB
    module Strategies
      class ClientAssertion
        attr_reader :credentials

        def initialize(credentials: ClientCredentials.default)
          @credentials = credentials
        end

        def call(uuid: SecureRandom.uuid)
          p "credentials.app_secret", credentials.app_secret
          JWT.encode(
            {
              iss: credentials.app_id,
              sub: credentials.app_id,
              aud: "https://priora.banksalt.com/api/oidc/demo_bank_ob_uk/tokens",
              iat: Time.now.to_i,
              exp: Time.now.to_i + 300,
              jti: uuid
            },
            ApiClient::CertCredentials.obseal.private_key,
            "RS256", { kid: "1" }
          )
        end
      end
    end
  end
end
