# frozen_string_literal: true

module SaltEdge
  module OB
    ConsentCreateResponse = ::Data.define(:external_id, :status, :permissions, :expired_at)

    class ConsentCreateEndpoint
      include Callable

      param :provider, default: -> { SaltEdge::Provider.ob }
      param :client, default: -> { ClientFactory.client_token_auth(provider:) }

      def call
        response = client.post("aisp/account-access-consents", body: {
          Data: {
            Permissions: %w[
              ReadAccountsBasic ReadAccountsDetail ReadBalances
              ReadTransactionsBasic ReadTransactionsDetail
              ReadTransactionsCredits ReadTransactionsDebits
            ],
            ExpirationDateTime: 89.days.from_now.utc.iso8601
            # TransactionFromDateTime: 90.days.ago.utc.iso8601,
            # TransactionToDateTime: Time.now.utc.iso861
          },
          Risk: {}
        })

        ConsentCreateResponse.new(
          external_id: response.dig("Data", "ConsentId"),
          status: response.dig("Data", "Status"),
          permissions: response.dig("Data", "Permissions"),
          expired_at: response.dig("Data", "ExpirationDateTime")&.to_datetime
        )
      end
    end
  end
end
