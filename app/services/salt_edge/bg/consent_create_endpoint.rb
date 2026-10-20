# frozen_string_literal: true

module SaltEdge
  module BG
    class ConsentCreateEndpoint
      include Callable

      param :redirect_url
      param :client, default: -> { ClientFactory.with_provider }

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
