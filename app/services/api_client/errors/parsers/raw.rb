# frozen_string_literal: true

module ApiClient
  module Errors
    module Parsers
      # Default error parser.
      class Raw
        MESSAGE_LIMIT = 200

        def parse(result)
          Details.new(code: nil, message: result.body.to_s.truncate(MESSAGE_LIMIT))
        end
      end
    end
  end
end
