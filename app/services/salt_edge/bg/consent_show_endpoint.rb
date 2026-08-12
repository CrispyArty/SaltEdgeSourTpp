# frozen_string_literal: true

module SaltEdge
  module BG
    ConsentShowEndpoint = ::Data.define(:consent_id, :client) do
      extend Callable

      def initialize(consent_id:, client: ClientFactory.with_provider) = super

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
