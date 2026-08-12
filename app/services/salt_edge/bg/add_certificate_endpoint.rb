# frozen_string_literal: true

module SaltEdge
  module BG
    AddCertificateEndpoint = ::Data.define(:client) do
      extend Callable

      def initialize(client: ClientFactory.global) = super

      def call
        client.post("tpp/certificates", body: {
          certificate: {
            name: "Sour Point certificate BG",
            type: "qseal"
          }
        })
      end
    end
  end
end
