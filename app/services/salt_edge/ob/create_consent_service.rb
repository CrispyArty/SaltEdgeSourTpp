module SaltEdge
  module OB
    class CreateConsentService
      extend Callable
      attr_reader :client

      def initialize(client: ClientFactory.regular)
        @client = client
      end

      def call
        client.post("aisp/account-access-consents", body: {
          Data: {
            Permissions: %w[ReadAccountsBasic ReadAccountsDetail ReadBalances ReadTransactionsBasic ReadTransactionsDetail ReadTransactionsCredits ReadTransactionsDebits],
            ExpirationDateTime: (Time.now + 89.days).utc.iso8601
            # TransactionFromDateTime: (Time.now - 90.days).utc.iso8601,
            # TransactionToDateTime: Time.now.utc.iso8601
          },
          Risk: {}
        })
      end
    end
  end
end
