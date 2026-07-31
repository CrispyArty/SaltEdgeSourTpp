module SaltEdge
  module OB
    class AddCertificateService < ApplicationService
      attr_reader :client

      def initialize(client: ClientFactory.global)
        @client = client
      end

      def call
        client.post("tpp/certificates", data: {
          data: {
            certificate: {
              pem: ApiClient::CertCredentials.obseal.cert.to_pem,
              name: "Sour Point certificate OB",
              type: "obseal"
            }
          }
        })
      end
    end
  end
end
