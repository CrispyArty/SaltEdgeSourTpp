# frozen_string_literal: true

module SaltEdge
  module OB
    class SoftwareCredentials
      def self.default
        @default ||= new(
          app_id: Rails.configuration.salt_edge[:tpp_client][:app_id],
          app_secret: Rails.configuration.salt_edge[:tpp_client][:app_secret]
        )
      end

      attr_reader :app_id, :app_secret

      def initialize(app_id:, app_secret:)
        @app_id = app_id
        @app_secret = app_secret
      end
    end
  end
end
