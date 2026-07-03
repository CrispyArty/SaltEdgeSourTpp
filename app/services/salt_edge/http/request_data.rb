# frozen_string_literal: true

module SaltEdge
  module Http
    # Pure immutable value object describing a fully-built request. Stores and exposes data only.
    RequestData = Data.define(:method, :url, :headers, :query, :body)
  end
end
