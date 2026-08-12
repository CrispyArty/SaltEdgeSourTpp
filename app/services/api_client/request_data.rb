# frozen_string_literal: true

module ApiClient
  RequestData = Data.define(:method, :url, :headers, :query, :body) # rubocop:disable Lint/DataDefineOverride
end
