# frozen_string_literal: true

module SaltEdge
  module OB
    class BuildAuthorizeLink
      include Callable

      param :consent_id
      param :provider, default: -> { SaltEdge::Provider.ob }
      param :state, default: -> { SecureRandom.hex(16) }
      param :credentials, default: -> { Credentials.default }
      param :redirect_uri, default: -> { Rails.configuration.salt_edge[:ob_callback_url] }
      param :client, default: -> { ClientFactory.base }

      def call
        client.get(".well-known/openid-configuration/#{provoder.code}") => {
          authorization_endpoint: auth_url
        }

        query = {
          client_id: credentials.app_id,
          response_type: "code",
          redirect_uri:,
          scope:,
          state:,
          # nonce:,
          request: jwt_request
        }.to_query.gsub("+", "%20")

        auth_url + "?" + query
      end

      private

      def scope = "openid accounts payments"

      def nonce = @nonce ||= SecureRandom.hex(16)

      def jwt_request
        JWT.encode(
          {
            iss: credentials.app_id,
            client_id: credentials.app_id,
            aud: Rails.configuration.salt_edge[:base_uri], # well-known "issuer"
            response_type: "code",
            redirect_uri:,
            scope:,
            state:,
            # nonce:,
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
