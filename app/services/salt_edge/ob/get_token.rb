module SaltEdge
  module OB
    class GetToken < ApplicationService
      attr_reader :client

      def initialize(client: ClientFactory.token)
        @client = client
      end

      def call
        assertion = Strategies::ClientAssertion.new.call

        client.post("tokens", data: {
          grant_type: "client_credentials",
          client_assertion_type: "urn:ietf:params:oauth:client-assertion-type:jwt-bearer",
          client_assertion: assertion
        })
      end
    end
  end
end
