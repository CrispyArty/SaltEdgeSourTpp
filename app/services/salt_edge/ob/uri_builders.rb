# frozen_string_literal: true

module SaltEdge
  module OB
    module UriBuilders
      def self.base(base_uri:)
        ApiClient::UriBuilders::Template.new(pattern: "#{base_uri}/%{endpoint}")
      end

      def self.provider(base_uri:, provider:)
        ApiClient::UriBuilders::Template.new(
          pattern: "#{base_uri}/api/#{provider}/open-banking/v3.1.11/%{endpoint}"
        )
      end

      def self.oidc(base_uri:, provider:)
        ApiClient::UriBuilders::Template.new(
          pattern: "#{base_uri}/api/oidc/#{provider}/%{endpoint}"
        )
      end
    end
  end
end
