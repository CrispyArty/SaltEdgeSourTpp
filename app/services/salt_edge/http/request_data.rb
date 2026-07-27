# frozen_string_literal: true

module SaltEdge
  module Http
    RequestData = Data.define(:method, :url, :headers, :query, :body)
  end
end
