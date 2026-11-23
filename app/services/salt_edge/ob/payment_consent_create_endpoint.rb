# frozen_string_literal: true

module SaltEdge
  module OB
    PaymentConsentCreateResponse = ::Data.define(:external_id, :status, :initiation)

    # POST pisp/<product> (domestic-payment-consents, international-payment-consents, ...)
    class PaymentConsentCreateEndpoint
      include Callable

      param :body
      param :product, default: "international-payment-consents"
      param :provider, default: -> { SaltEdge::Provider.ob }
      param :client, default: -> { ClientFactory.client_token_auth(provider:) }

      def call
        response = client.post("pisp/#{product}", body:, headers: {
          "x-fapi-interaction-id" => SecureRandom.uuid,
          "x-fapi-customer-ip-address" => "127.0.0.1",
          "Idempotency-Key" => SecureRandom.hex(16),
          "Accept" => "application/json"
        })

        response

        # PaymentConsentCreateResponse.new(
        #   external_id: response.dig("Data", "ConsentId"),
        #   status: response.dig("Data", "Status"),
        #   initiation: response.dig("Data", "Initiation")
        # )
      end
    end
  end
end
