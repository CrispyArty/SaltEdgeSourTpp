# frozen_string_literal: true

module SaltEdge
  module OB
    module UriBuilders
      def self.global(base_uri:)
        ApiClient::UriBuilders::Template.new(pattern: "#{base_uri}/api/open-banking/v3.1/%{endpoint}")
      end

      def self.token(base_uri:, provider:)
        ApiClient::UriBuilders::Template.new(pattern: "#{base_uri}/api/oidc/#{provider}/%{endpoint}")
      end
    end
  end
end
