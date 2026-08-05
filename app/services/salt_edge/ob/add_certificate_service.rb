module SaltEdge
  module OB
    class AddCertificateService
      extend Callable
      attr_reader :client

      def initialize(client: ClientFactory.regular)
        @client = client
      end

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
