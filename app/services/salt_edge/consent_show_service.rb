module SaltEdge
  class ConsentShowService < ApplicationService
    attr_reader :consent_id, :client

    def initialize(consent_id:, client: ClientFactory.with_provider)
      @consent_id = consent_id
      @client = client
    end

    def call
      response = client.get("consents/#{consent_id}")

      {
        consent_status: response['consentStatus'],
        sca_redirect_link: response.dig('_links', 'scaRedirect', 'href')
      }
    end
  end
end