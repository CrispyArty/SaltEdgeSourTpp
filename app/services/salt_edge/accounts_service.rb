module SaltEdge
  class AccountsService < ApplicationService
    attr_reader :consent_id, :client

    def initialize(consent_id:, client: ClientFactory.with_provider)
      @consent_id = consent_id
      @client = client
    end

    def call
      data = client.get(
        'accounts',
        headers: { 'Consent-Id' => consent_id },
        data: { withBalance: true }
      )

      data.with_indifferent_access
    end
  end
end