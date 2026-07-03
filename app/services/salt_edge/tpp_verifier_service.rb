module SaltEdge
  class TppVerifierService < ApplicationService
    attr_reader :client

    def initialize(client: ClientFactory.base)
      @client = client
    end

    def call
      test_cert = ::File.read(Rails.root.join("storage", "certificates", "client_signed_certificate.crt").to_s)

      response = client.post(
        "tpp_verifiers/v2/certificates",
        data: {
          data: {
            certificate: test_cert
          }
        },
      )

      p "--response", JSON.parse(response.body)
    end
  end
end
