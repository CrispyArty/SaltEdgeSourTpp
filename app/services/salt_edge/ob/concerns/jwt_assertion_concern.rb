# frozen_string_literal: true

module SaltEdge
  module OB
    module JWTAssertionConcern
      private

      def create_assertion(uuid: SecureRandom.uuid)
        JWT.encode(
          {
            iss: credentials.app_id,
            sub: credentials.app_id,
            aud: client.uri_builder.build("tokens"),
            iat: Time.now.to_i,
            exp: Time.now.to_i + 300,
            jti: uuid
          },
          credentials.private_key,
          "RS256", { kid: "1" }
        )
      end
    end
  end
end
