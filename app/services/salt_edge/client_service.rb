require "openssl"
require "base64"
require "securerandom"
require "excon"
require "time"
require "json"

module SaltEdge
  class ClientService
    ApiError = Class.new(StandardError)
    attr_reader :uri_builder, :auth

    def initialize(uri_builder:, auth: TppSignatureAuth.new)
      @uri_builder = uri_builder
      @auth = auth
    end

    def build_url(path)
      uri_builder.build(path)
    end

    def get(path, headers: {}, data: {})
      response = Excon.get(
        build_url(path),
        headers: auth.headers_for(headers),
        query: data
      )

      raise ApiError if response.status >= 500

      ApiResult.new(status: response.status, headers: response.headers, body: response.body)
    end

    def post(path, headers: {}, data: {})
      body = data.to_json
      response = Excon.post(
        build_url(path),
        headers: auth.headers_for(headers, body: body).merge({
          "Content-Type" => "application/json"
        }),
        body: body
      )

      raise ApiError if response.status >= 500

      ApiResult.new(status: response.status, headers: response.headers, body: response.body)
    end
  end

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

  class AppAuth
    def initialize(app_id:, app_secret:)
      @app_id = app_id
      @app_secret = app_secret
    end

    def headers_for(headers, body: nil)
      headers.merge("App-Id" => @app_id, "App-Secret" => @app_secret)
    end
  end
end
