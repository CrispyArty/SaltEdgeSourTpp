# frozen_string_literal: true

module SaltEdge
  Provider = Data.define(:code, :base_uri) do
    def self.bg
      config = Rails.configuration.salt_edge
      new(code: config[:bg_provider], base_uri: config[:base_uri])
    end

    def self.ob
      config = Rails.configuration.salt_edge
      new(code: config[:ob_provider], base_uri: config[:base_uri])
    end
  end
end
