module SaltEdge
  class ConsentCreateService < ApplicationService
    attr_reader :redirect_url, :client

    def initialize(redirect_url:, client: ClientFactory.with_provider)
      @redirect_url = redirect_url
      @client = client
    end

    def call
      response = client.post(
        'consents',
        headers: {
          'TPP-Redirect-URI' => redirect_url,
          'TPP-Redirect-Preferred' => 'true'
        },
        data: {
          recurringIndicator: true,
          frequencyPerDay: 4,
          validUntil: 30.days.from_now.utc.strftime("%Y-%m-%d"), # "2026-04-30"
          access: {
            allPsd2: "allAccounts"
          }
        }
      )

      {
        consent_id: response['consentId'],
        consent_status: response['consentStatus']
      }
    end
  end
end