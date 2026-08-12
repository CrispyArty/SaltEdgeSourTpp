# frozen_string_literal: true

module SaltEdge
  module OB
    ConsentCreateResponse = ::Data.define(:external_id, :status, :permissions, :expired_at)

    ConsentCreateEndpoint = ::Data.define(:client) do
      extend Callable

      def initialize(client: ClientFactory.initial) = super

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
            # TransactionToDateTime: Time.now.utc.iso8601
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
