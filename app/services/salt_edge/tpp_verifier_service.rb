module SaltEdge
  class TppVerifierService
    extend Callable

    attr_reader :client

    config = Rails.configuration.salt_edge
    CLIENT = ApiClient::Client.new(
      uri_builder: ApiClient::UriBuilders.base(base_uri: config[:base_uri]),
      auth: ApiClient::Strategies::AppAuth.new(
        app_id: config[:tpp_verifier][:app_id],
        app_secret: config[:tpp_verifier][:app_secret]
      ),
      sender: ApiClient::Logging::Sender.new(inner: ApiClient::Sender.new, logger: ApiClient::Logging::ApiRequestLogger.new)
    )

    def initialize(client: CLIENT)
      @client = client
    end

    def call
      test_cert = ::File.read(Rails.root.join("storage", "certificates", "client_signed_certificate.crt").to_s)

      response = client.post(
        "tpp_verifiers/v2/certificates",
        body: {
          data: {
            certificate: test_cert
          }
        },
      )

      p "--response", JSON.parse(response.body)
    end
  end
end
