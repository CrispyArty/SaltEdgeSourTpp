# frozen_string_literal: true

module SaltEdge
  Provider = Data.define(:code) do
    def self.bg
      config = Rails.configuration.salt_edge
      new(code: config[:bg_provider])
    end

    def self.ob
      config = Rails.configuration.salt_edge
      new(code: config[:ob_provider])
    end
  end
end
