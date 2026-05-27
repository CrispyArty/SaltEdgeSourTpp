module SaltEdge
  class TppVerifierService < ApplicationService
    attr_reader :client

    def initialize(client: ClientService.new(
        uri_builder: UriBuilders::Base.new
      ))
      @client = client
    end

    def call
      test_cert = ::File.read(Rails.root.join("storage", "certificates", "client_signed_certificate.crt").to_s)

      # p test_cert

      builder = UriBuilders::Base.new

      p builder.build("tpp_verifiers/v2/certificates")

      app_id = "fi1MZGWp7rn4oLkKBL68vw"
      secret_id = "4flN119c28Uo4n0JvQ-Xzbq1PspXN4x3geaa2iLsE4U"

      # app_id = "wirecard_test_id"
      # secret_id = "wirecard_test_secret"
      response = Excon.post(
        builder.build("tpp_verifiers/v2/certificates"),
        # "https://priora.saltedge.com/api/tpp_verifiers/v2/certificates",
        headers: {
          "App-Id" => app_id,
          "App-Secret" => secret_id,
          "Content-Type" => "application/json"
        },
        body: {
          data: {
            certificate: test_cert
          }
        }.to_json,
        # body: "{ data: { certificate: #{test_cert} } }"
      )

      p "--response", JSON.parse(response.body)

      # client.post("tpp_verifiers/v2/certificates", data: {
      #   certificate: {
      #     name: "Sour Point certificate",
      #     type: "qseal"
      #   },
      #   headers: {
      #     "App-Id" => app_id,
      #     "App-Secret" => secret_id
      #   },
      #   body: {
      #     data: {
      #       certificate: test_cert
      #     }
      #   }
      #   # body: "{ data: { certificate: #{test_cert} } }"
      # })
    end
  end
end
