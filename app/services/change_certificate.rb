class ChangeCertificate < ApplicationService
  def call
    test_cert = ::File.read(Rails.root.join("storage", "certificates", "client_signed_certificate.crt").to_s)

    cert = OpenSSL::X509::Certificate.new(test_cert)
  end
end
