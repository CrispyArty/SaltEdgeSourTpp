# frozen_string_literal: true

module SaltEdge
  module BG
    class AddCertificateEndpoint
      include Callable

      param :client, default: -> { ClientFactory.global }

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
