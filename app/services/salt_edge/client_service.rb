require 'openssl'
require 'base64'
require 'securerandom'
require 'excon'
require 'time'
require 'json'

module SaltEdge
  class ClientService
    ApiError = Class.new(StandardError)

    attr_reader :client

    def initialize(uri_builder:)
      @uri_builder = uri_builder

      # TODO raise error if cert or private_key doesnt exists
      @certfile = File.read(Rails.root.join("storage", "certificates", "client_signed_certificate.crt"))
      @private_key = OpenSSL::PKey::RSA.new(File.read(Rails.root.join("storage", "certificates", "client_private.key")))
      @tpp_signature_certificate = Base64.strict_encode64(@certfile)
      @cert = OpenSSL::X509::Certificate.new(@certfile)
    end

    def get(path, headers: {}, data: {})

      p "=======GET #{uri_builder.build(path)}"

      response = Excon.get(
        uri_builder.build(path),
        headers: generate_headers(headers),
        query: data
      )

      p '-------responseGet', response, response.body
      raise ApiError if response.status >= 500

      JSON.parse(response.body)
    end

    def post(path, headers: {}, data: {})
      # p "=======POST #{uri_builder.build(path)}"

      body = data.to_json
      response = Excon.post(
        uri_builder.build(path),
        headers: generate_headers(headers, body).merge({
          "Content-Type" => "application/json"
        }),
        body: body
      )

      p '-------responsePost', response, response.body

      raise ApiError if response.status >= 500


      JSON.parse(response.body)
    end

    private

    attr_accessor :cert, :tpp_signature_certificate, :certfile, :private_key, :uri_builder

    def generate_headers(headers, body = '')
      sign, rest = separate_headers(headers)

      sign_headers = pre_headers(body).merge(sign)

      sign_headers.merge(
        "TPP-Signature-Certificate" => tpp_signature_certificate,
        "Signature" => signature(sign_headers),
      ).merge(rest)
    end


    def pre_headers(body)
      {
        "X-Request-ID" => SecureRandom.uuid,
        "Digest" => digest(body),
        "Date" => Time.now.utc.httpdate,
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

      [headers_for_sign, rest]
    end

    def digest(body)
      digest = OpenSSL::Digest::SHA256.new
      hash = digest.digest(body)
      "SHA-256=#{Base64.strict_encode64(hash)}"
    end

    def signature(headers)
      key_id = "SN=#{cert.serial.to_s(16).upcase},CA=#{cert.issuer.to_s}"
      algorithm = "rsa-sha256"
      header_keys = headers.keys.join(' ').downcase

      headers_str = headers.map { |k, v| "#{k.downcase}: #{v}" }.join("\n")
      sign = private_key.sign(OpenSSL::Digest::SHA256.new, headers_str)
      signature = Base64.strict_encode64(sign)

      "keyId=\"#{key_id}\",algorithm=\"#{algorithm}\",headers=\"#{header_keys}\",signature=\"#{signature}\""
    end

  end
end