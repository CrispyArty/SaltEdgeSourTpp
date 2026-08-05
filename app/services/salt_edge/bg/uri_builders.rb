# frozen_string_literal: true

module SaltEdge
  module BG
    module UriBuilders
      def self.provider(base_uri:, provider:)
        ApiClient::UriBuilders::Template.new(
          pattern: "#{base_uri}/#{provider}/api/berlingroup/v1/%{endpoint}"
        )
      end

      def self.global(base_uri:)
        ApiClient::UriBuilders::Template.new(
          pattern: "#{base_uri}/api/berlingroup/v1/%{endpoint}"
        )
      end
    end
  end
end
