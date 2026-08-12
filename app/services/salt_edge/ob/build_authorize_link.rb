# frozen_string_literal: true

module SaltEdge
  module OB
    class BuildAuthorizeLink
      extend Callable
      attr_reader :consent_id, :credentials, :redirect, :scope, :state, :nonce, :auth_url

      def initialize(
        consent_id:,
        auth_url:,
        credentials: Credentials.default
      )
        @consent_id = consent_id
        @credentials = credentials
        @redirect = Rails.configuration.salt_edge[:ob_callback_url]
        @scope = "openid accounts"
        @state = SecureRandom.hex(16)
        @nonce = SecureRandom.hex(16)
        @auth_url = auth_url
      end

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

        # url = ProviderConfig.find_by!(code: provider.code).authorization_endpoint

        auth_url + "?" + query
      end

      private

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
