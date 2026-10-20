# frozen_string_literal: true

module SaltEdge
  module BG
    class ConsentShowEndpoint
      include Callable

      param :consent_id
      param :client, default: -> { ClientFactory.with_provider }

      def call
        response = client.get("consents/#{consent_id}")

        {
          consent_status: response["consentStatus"],
          sca_redirect_link: response.dig("_links", "scaRedirect", "href")
        }
      end
    end
  end
end
