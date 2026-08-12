# frozen_string_literal: true

module SaltEdge
  module OB
    AccountsEndpoint = ::Data.define(:client) do
      extend Callable

      def call
        client.get("aisp/accounts11", headers: {
          "x-fapi-interaction-id" => SecureRandom.uuid,
          "x-fapi-customer-ip-address" => "127.0.0.1",
          "Accept" => "application/json"
        })
      end
    end
  end
end
