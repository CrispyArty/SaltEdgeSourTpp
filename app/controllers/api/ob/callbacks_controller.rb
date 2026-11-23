module Api
  module OB
    class CallbacksController < ActionController::API
      def success
        code, state = params.expect(:code, :state)
        consent = OBConsent.find_by!(state: state)

        token_response = SaltEdge::OB::TokenAuthorizationCodeEndpoint.call(
          code: code,
          provider: consent.provider_code
        )

        token = OBApiToken.create!(token_response.attributes.merge(ob_consent_id: consent.id))

        render json: {
          consent: consent.to_json,
          token: token
        }
      end

      private

      def permitted_params
        params.expect(:code, :state)
      end
    end
  end
end
