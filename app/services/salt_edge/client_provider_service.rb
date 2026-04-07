require 'openssl'
require 'base64'
require 'securerandom'
require 'excon'
require 'time'
require 'securerandom'

module SaltEdge
  class ClientProviderService
    attr_reader :client

    def initialize

    end

    def get(path, headers, data)
      Excon.get(
        endpoint(path),
        headers: generate_headers(headers),
        query: data
      )
    end

    def post(path, headers, data)
      body = data.to_json
      Excon.post(
        endpoint(path),
        headers: generate_headers(headers, body).merge({
          "Content-Type" => "application/json"
        }),
        body: body
      )
    end

    private

    attr_accessor :cert, :tpp_signature_certificate, :certfile, :private_keyl, :conf

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

    def endpoint(path)
      "#{conf[:base_uri]}/api/berlingroup/#{path}"
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