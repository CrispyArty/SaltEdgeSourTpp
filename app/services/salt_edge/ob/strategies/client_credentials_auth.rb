# frozen_string_literal: true

module SaltEdge
  module OB
    module Strategies
      class ClientCredentialsAuth
        attr_reader :credentials

        def initialize(credentials: Credentials.default)
          @credentials = credentials
        end

        def headers_for(headers, _body = nil)
          headers.merge("Authorization" => "Bearer #{create_token}")
        end

        private

        def create_token
          TokenClientCredentialsEndpoint.call(credentials: credentials)
        end
      end
    end
  end
end
