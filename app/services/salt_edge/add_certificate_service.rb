module SaltEdge
  class AddCertificateService < ApplicationService
    attr_reader :client

    def initialize(client: ClientFactory.global)
      @client = client
    end

    def call
      client.post('tpp/certificates', data: {
        certificate: {
          name: "Sour Point certificate",
          type: "qseal"
        }
      })
    end
  end
end