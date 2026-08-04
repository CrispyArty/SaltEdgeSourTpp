# frozen_string_literal: true

module SaltEdge
  module OB
    module Strategies
      class ClientCredentialsAuth
        attr_reader :software_credentials, :cert_credentials

        def initialize(
          software_credentials: SoftwareCredentials.default,
          cert_credentials: CertCredentials.obseal
        )
          @software_credentials = software_credentials
          @cert_credentials = cert_credentials
        end

        def headers_for(headers, body: nil)
          headers.merge("Authorization" => "Bearer #{create_token}")
        end

        private

        def create_token
          TokenClientCredentialsService.call(
            software_credentials: software_credentials,
            cert_credentials: cert_credentials
          )
        end
      end
    end
  end
end
