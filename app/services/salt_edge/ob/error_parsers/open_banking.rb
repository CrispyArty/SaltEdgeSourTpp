# frozen_string_literal: true

module SaltEdge
  module OB
    module ErrorParsers
      # Open Banking UK: {"Code","Id","Message","Errors":[{"ErrorCode","Message","Path","Url"}]}
      # A 401 carries no body at all, so every lookup has to tolerate an empty hash.
      class OpenBanking
        def parse(result)
          body = result.parsed_or_empty
          error = body.dig("Errors", 0) || {}

          ApiClient::Errors::Details.new(
            code: error["ErrorCode"] || body["Code"],
            message: error["Message"] || body["Message"]
          )
        end
      end
    end
  end
end
