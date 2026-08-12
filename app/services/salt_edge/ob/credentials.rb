# frozen_string_literal: true

module SaltEdge
  module OB
    class Credentials
      extend Forwardable

      def self.default
        @default ||= new(
          cert_credentials: CertCredentials.obseal,
          app_id: Rails.configuration.salt_edge[:tpp_client][:app_id],
          app_secret: Rails.configuration.salt_edge[:tpp_client][:app_secret]
        )
      end

      def_delegators :cert_credentials, :cert, :private_key
      attr_reader :cert_credentials, :app_id, :app_secret

      def initialize(cert_credentials:, app_id:, app_secret:)
        @cert_credentials = cert_credentials
        @app_id = app_id
        @app_secret = app_secret
      end
    end
  end
end
