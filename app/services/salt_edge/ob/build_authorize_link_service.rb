# frozen_string_literal: true

module SaltEdge
  module OB
    class BuildAuthorizeLinkService
      extend Callable
      attr_reader :consent_id, :software_credentials, :cert_credentials, :redirect, :scope, :state, :nonce, :provider

      def initialize(
        consent_id:,
        provider: SaltEdge::Provider.ob,
        software_credentials: SoftwareCredentials.default,
        cert_credentials: CertCredentials.obseal
      )
        @consent_id = consent_id
        @software_credentials = software_credentials
        @cert_credentials = cert_credentials
        @redirect = Rails.configuration.salt_edge[:ob_callback_url]
        @scope = "openid accounts"
        @state = SecureRandom.hex(16)
        @nonce = SecureRandom.hex(16)
        @provider = provider
      end

      def call
        query = {
          client_id: software_credentials.app_id,
          redirect_uri: redirect,
          scope: scope,
          response_type: "code",
          state: state,
          nonce: nonce,
          request: jwt_request
        }.to_query

        "https://connector.banksalt.com/demo_bank_ob_v3_dot1_dot11_uk_sandbox/ob/v1/oauth2/authorize?#{query}"
      end

      private

      def jwt_request
        JWT.encode(
          {
            iss: software_credentials.app_id,
            client_id: software_credentials.app_id,
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
          cert_credentials.private_key, "RS256"
        )
      end
    end
  end
end
