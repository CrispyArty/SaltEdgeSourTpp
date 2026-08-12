# frozen_string_literal: true

module ApiClient
  module Errors
    # What an error parser extracts from a failed response.
    Details = ::Data.define(:code, :message)
  end
end
