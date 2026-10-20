# frozen_string_literal: true

module SaltEdge
  module OB
    class AddCertificateEndpoint
      include Callable

      param :client, default: -> { ClientFactory.base }

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
