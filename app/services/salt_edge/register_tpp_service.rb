module SaltEdge
  class RegisterTppService
    def initialize(client: ClientFactory.global)
      @client = client
    end

    def call(consent_id:)
      response = client.get('v1/accounts', { 'Consent-Id' => consent_id }, {
        withBalance: true
      })

      response.body
    end
  end
end