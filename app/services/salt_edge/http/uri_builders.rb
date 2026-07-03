# frozen_string_literal: true

module SaltEdge
  module Http
    module UriBuilders
      Template = Data.define(:pattern) do
        def build(endpoint)
          sprintf(pattern, endpoint: endpoint)
        end
      end

      def self.provider(base_uri:, provider:)
        Template.new(pattern: "#{base_uri}/#{provider}/api/berlingroup/v1/%{endpoint}")
      end

      def self.global(base_uri:)
        Template.new(pattern: "#{base_uri}/api/berlingroup/v1/%{endpoint}")
      end

      def self.base(base_uri:)
        Template.new(pattern: "#{base_uri}/api/%{endpoint}")
      end
    end
  end
end
