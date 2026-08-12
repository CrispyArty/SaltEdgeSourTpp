# frozen_string_literal: true

module SaltEdge
  module BG
    AccountsEndpoint = ::Data.define(:consent_id, :client) do
      extend Callable

      def initialize(consent_id:, client: ClientFactory.with_provider) = super

      def call
        data = client.get(
          "accounts",
          headers: { "Consent-Id" => consent_id },
          query: { withBalance: true }
        )

        data.with_indifferent_access
      end
    end
  end
end
