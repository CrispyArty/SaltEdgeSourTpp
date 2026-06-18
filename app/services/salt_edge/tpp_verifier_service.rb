module SaltEdge
  class TppVerifierService < ApplicationService
    attr_reader :client

    def initialize(client: ClientFactory.base)
      @client = client
    end

    def call
      test_cert = ::File.read(Rails.root.join("storage", "certificates", "client_signed_certificate.crt").to_s)

      # app_id = "fi1MZGWp7rn4oLkKBL68vw"
      # secret_id = "4flN119c28Uo4n0JvQ-Xzbq1PspXN4x3geaa2iLsE4U"

      # app_id = "wirecard_test_id"
      # secret_id = "wirecard_test_secret"

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
