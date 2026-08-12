# frozen_string_literal: true

module SaltEdge
  module OB
    module Strategies
      class AccessTokenAuth
        def initialize(token_provider:)
          @token_provider = token_provider
        end

        def headers_for(headers, _body = nil)
          @token_provider.refresh! if @token_provider.expired?

          headers.merge("Authorization" => "Bearer #{@token_provider.access_token}")
        end
      end
    end
  end
end
