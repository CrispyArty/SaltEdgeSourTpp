# frozen_string_literal: true

module SaltEdge
  module BG
    class ProductFieldsEndpoint
      include Callable

      param :client, default: -> { ClientFactory.global }

      def call
        data = client.get(
          "aspsps/product_templates",
          query: { provider_code: "bov_mt_sandbox", regular_payment: true }
        )

        data.with_indifferent_access
      end
    end
  end
end
