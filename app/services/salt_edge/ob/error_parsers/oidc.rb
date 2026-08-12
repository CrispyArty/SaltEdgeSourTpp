# frozen_string_literal: true

module SaltEdge
  module OB
    module ErrorParsers
      # OIDC token endpoints: {"code","error","error_description"}
      # "error" is a demodulized class name ("InvalidRequest"), not an OAuth2 code.
      class Oidc
        def parse(result)
          body = result.parsed_or_empty

          ApiClient::Errors::Details.new(code: body["error"], message: body["error_description"])
        end
      end
    end
  end
end
