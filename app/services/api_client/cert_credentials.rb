# frozen_string_literal: true

module ApiClient
  class CertCredentials
    MissingError = Class.new(StandardError)

    def self.default
      @default ||= load(
        cert_path: Rails.root.join("storage/certificates/client_signed_certificate.crt"),
        key_path: Rails.root.join("storage/certificates/client_private.key")
      )
    end

    def self.load(cert_path:, key_path:)
      [ cert_path, key_path ].each do |path|
        raise MissingError, "certificate file not found: #{path}" unless File.exist?(path)
      end
      new(pem: File.read(cert_path), private_key: File.read(key_path))
    end

    attr_reader :pem, :cert, :private_key

    def initialize(pem:, private_key:)
      @pem = pem
      @cert = OpenSSL::X509::Certificate.new(pem)
      @private_key = OpenSSL::PKey::RSA.new(private_key)
    end
  end
end
