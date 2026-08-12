# frozen_string_literal: true

module SaltEdge
  module BG
    ConsentCreateEndpoint = ::Data.define(:redirect_url, :client) do
      extend Callable

      def initialize(redirect_url:, client: ClientFactory.with_provider) = super

      def call
        response = client.post(
          "consents",
          headers: {
            "TPP-Redirect-URI" => redirect_url,
            "TPP-Redirect-Preferred" => "true"
          },
          body: {
            recurringIndicator: true,
            frequencyPerDay: 4,
            validUntil: 30.days.from_now.utc.strftime("%Y-%m-%d"), # "2026-04-30"
            access: {
              allPsd2: "allAccounts"
            }
          }
        )

        {
          consent_id: response["consentId"],
          consent_status: response["consentStatus"]
        }
      end
    end
  end
end
