# frozen_string_literal: true

module ApiClient
  module UriBuilders
    Template = Data.define(:pattern) do
      def build(endpoint)
        sprintf(pattern, endpoint: endpoint)
      end
    end

    def self.base(base_uri:)
      Template.new(pattern: "#{base_uri}/api/%{endpoint}")
    end
  end
end
