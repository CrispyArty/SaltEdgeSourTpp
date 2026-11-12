# frozen_string_literal: true

module SaltEdge
  module OB
    class AccountTransactionsEndpoint
      include Callable

      param :client
      param :account_id
      param :fromDate, default: -> { "2026-11-01" }
      param :toDate, default: -> { "2026-11-08" }
      param :limit, optional: true
      param :offset, optional: true

      def call
        client.get("aisp/accounts/#{account_id}/transactions",
          headers: {
            "x-fapi-interaction-id" => SecureRandom.uuid,
            "x-fapi-customer-ip-address" => "127.0.0.1",
            "Accept" => "application/json"
          },
          query: {
            limit:,
            offset:
            # "fromBookingDateTime" => fromDate,
            # "toBookingDateTime" => toDate
          }.compact
        )
      end
    end
  end
end
