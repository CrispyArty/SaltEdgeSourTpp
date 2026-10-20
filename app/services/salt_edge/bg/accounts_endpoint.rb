# frozen_string_literal: true

module SaltEdge
  module BG
    class AccountsEndpoint
      include Callable

      param :consent_id
      param :client, default: -> { ClientFactory.with_provider }

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
