module SaltEdge
  class AccountsService
    def initialize(client: ClientFactory.with_provider)
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