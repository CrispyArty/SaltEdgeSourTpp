# frozen_string_literal: true
module SaltEdge
  module UriBuilders
    class UriBuilder
      attr_accessor :base_uri
      def initialize(*, **)
        @base_uri = Rails.configuration.salt_edge[:base_uri]
      end

      def build(_endpoint)
        raise NotImplementedError
      end
    end

    class Provider < UriBuilder
      def initialize(provider:)
        @provider = provider
        super
      end

      def build(endpoint)
        "#{base_uri}/#{@provider}/api/berlingroup/v1/#{endpoint}"
      end
    end

    class Global < UriBuilder
      def build(endpoint)
        "#{base_uri}/api/berlingroup/v1/#{endpoint}"
      end
    end

  end
end
