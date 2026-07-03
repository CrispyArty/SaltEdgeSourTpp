# frozen_string_literal: true

module SaltEdge
  module Strategies
    class TppSignatureAuth
      attr_accessor :cert, :tpp_signature_certificate, :certfile, :private_key

      def initialize
        # TODO raise error if cert or private_key doesnt exists
        @certfile = File.read(Rails.root.join("storage", "certificates", "client_signed_certificate.crt"))
        @private_key = OpenSSL::PKey::RSA.new(File.read(Rails.root.join("storage", "certificates", "client_private.key")))
        @tpp_signature_certificate = Base64.strict_encode64(@certfile)
        @cert = OpenSSL::X509::Certificate.new(@certfile)
      end

      def headers_for(headers, body: "")
        sign_headers, rest = separate_headers(headers)

        sign_headers = pre_headers(body).merge(sign_headers)

        sign = signature(sign_headers)

        sign_headers.merge(
          "TPP-Signature-Certificate" => tpp_signature_certificate,
          "Signature" => sign,
        ).merge(rest)
      end

      def pre_headers(body)
        {
          "X-Request-ID" => SecureRandom.uuid,
          "Digest" => digest(body),
          "Date" => Time.now.utc.httpdate
        }
      end

      def separate_headers(headers)
        headers_for_sign = {}
        rest = {}

        headers.each do |k, v|
          if %w[psu-id psu-corporate-id tpp-redirect-uri].include?(k.downcase)
            headers_for_sign[k] = v
          else
            rest[k] = v
          end
        end

        [ headers_for_sign, rest ]
      end

      def digest(body)
        digest = OpenSSL::Digest::SHA256.new
        hash = digest.digest(body)
        "SHA-256=#{Base64.strict_encode64(hash)}"
      end

      def signature(headers)
        key_id = "SN=#{cert.serial.to_s(16).upcase},CA=#{cert.issuer}"
        algorithm = "rsa-sha256"
        header_keys = headers.keys.join(" ").downcase

        headers_str = headers.map { |k, v| "#{k.downcase}: #{v}" }.join("\n")
        sign = private_key.sign(OpenSSL::Digest::SHA256.new, headers_str)
        signature = Base64.strict_encode64(sign)

        "keyId=\"#{key_id}\",algorithm=\"#{algorithm}\",headers=\"#{header_keys}\",signature=\"#{signature}\""
      end
    end
  end
end
