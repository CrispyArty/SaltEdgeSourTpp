# frozen_string_literal: true

module SaltEdge
  module OB
    AddCertificateEndpoint = ::Data.define(:client) do
      extend Callable

      def initialize(client: ClientFactory.base) = super

      def call
        client.post("tpp/certificates", body: {
          data: {
            certificate: {
              pem: CertCredentials.obseal.cert.to_pem,
              name: "Sour Point certificate OB",
              type: "obseal"
            }
          }
        })
      end
    end
  end
end
