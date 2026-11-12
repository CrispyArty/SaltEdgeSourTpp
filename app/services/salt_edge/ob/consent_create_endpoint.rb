# frozen_string_literal: true

module SaltEdge
  module OB
    ConsentCreateResponse = ::Data.define(:external_id, :status, :permissions, :expired_at)

    class ConsentCreateEndpoint
      include Callable

      param :provider, default: -> { SaltEdge::Provider.ob }
      param :client, default: -> { ClientFactory.client_token_auth(provider:) }
      param :transactionFromDateTime, default: -> { 90.days.ago.utc.iso8601 }
      param :transactionToDateTime, default: -> { Time.zone.parse("2026-11-08").utc.iso8601 }

      def call
        response = client.post("aisp/account-access-consents", body: {
          Data: {
            Permissions: %w[
              ReadAccountsBasic ReadAccountsDetail ReadBalances
              ReadTransactionsBasic ReadTransactionsDetail
              ReadTransactionsCredits ReadTransactionsDebits
            ],
            ExpirationDateTime: 89.days.from_now.utc.iso8601
            # TransactionFromDateTime: transactionFromDateTime,
            # TransactionToDateTime: transactionToDateTime
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
