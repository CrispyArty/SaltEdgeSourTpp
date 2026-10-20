# frozen_string_literal: true

module SaltEdge
  module OB
    module ErrorParsers
      # OIDC token endpoints errors: {"code","error","error_description"}
      class Oidc
        def parse(result)
          body = result.parsed_or_empty

          ApiClient::Errors::Details.new(code: body["error"], message: body["error_description"])
        end
      end
    end
  end
end
