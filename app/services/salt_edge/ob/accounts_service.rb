# frozen_string_literal: true

module SaltEdge
  module OB
    class AccountsService
      extend Callable
      attr_reader :client, :access_token

      def initialize(access_token:, client: ClientFactory.base)
        @client = client
        @access_token = access_token
      end

      def call
        client.get("aisp/accounts", headers: {
          "Authorization" => "Bearer #{access_token}",
          "x-fapi-interaction-id" => SecureRandom.uuid,
          "x-fapi-customer-ip-address" => "127.0.0.1",
          "Accept" => "application/json"
        })
      end
    end
  end
end
