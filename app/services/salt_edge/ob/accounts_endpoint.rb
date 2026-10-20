# frozen_string_literal: true

module SaltEdge
  module OB
    class AccountsEndpoint
      include Callable

      param :client

      def call
        client.get("aisp/accounts", headers: {
          "x-fapi-interaction-id" => SecureRandom.uuid,
          "x-fapi-customer-ip-address" => "127.0.0.1",
          "Accept" => "application/json"
        })
      end
    end
  end
end
