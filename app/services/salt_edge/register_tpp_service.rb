module SaltEdge
  class RegisterTppService < ApplicationService
    attr_reader :client

    def initialize(client: ClientFactory.global)
      @client = client
    end

    def call
      client.post('tpp/register', data: {
        company: {
          address: "Test address",
          email: "crispykindle@gmail.com",
          name: "Test name",
          phone_number: "+1 (212) 555-0100",
          zip_code: "GB",
          city: "Test city"
        },
        representative: {
          email: "crispykindle@gmail.com",
          name: "Test Name"
        },
        certificate: {
          name: "Sour Point certificate",
          type: "qseal"
        }
      })
    end
  end
end