# frozen_string_literal: true

module SaltEdge
  module BG
    # Berlin Group: {"tppMessages":[{"category","code","text","path"}]}
    class ErrorParser
      def parse(result)
        message = result.parsed_or_empty.dig("tppMessages", 0) || {}

        ApiClient::Errors::Details.new(code: message["code"], message: message["text"])
      end
    end
  end
end
