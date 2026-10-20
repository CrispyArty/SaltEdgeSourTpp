# frozen_string_literal: true

module SaltEdge
  module OB
    class BuildAuthorizeLink
      include Callable

      param :consent_id
      param :auth_url
      param :state, default: -> { SecureRandom.hex(16) }
      param :credentials, default: -> { Credentials.default }

      def call
        query = {
          client_id: credentials.app_id,
          redirect_uri: redirect,
          scope: scope,
          response_type: "code",
          state: state,
          nonce: nonce,
          request: jwt_request
        }.to_query

        auth_url + "?" + query
      end

      private

      def redirect = Rails.configuration.salt_edge[:ob_callback_url]

      def scope = "openid accounts"

      def nonce = @nonce ||= SecureRandom.hex(16)

      def jwt_request
        JWT.encode(
          {
            iss: credentials.app_id,
            client_id: credentials.app_id,
            aud: Rails.configuration.salt_edge[:base_uri], # well-known "issuer"
            response_type: "code",
            redirect_uri: redirect,
            scope: scope,
            state: state,
            nonce: nonce,
            max_age: 3600,
            claims: {
              id_token: {
                openbanking_intent_id: { value: consent_id, essential: true },
                acr: {
                  essential: true,
                  values: %w[urn:openbanking:psd2:sca urn:openbanking:psd2:ca]
                }
              }
            }
          },
          credentials.private_key, "RS256"
        )
      end
    end
  end
end
