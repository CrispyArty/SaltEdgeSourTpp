module SaltEdge
  module BG
    class AddCertificateService
      extend Callable
      attr_reader :client

      def initialize(client: ClientFactory.global)
        @client = client
      end

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
