require 'openssl'

namespace :salt do
  def create_private_key(file_path)
    key = OpenSSL::PKey::RSA.new(2048)

    File.open(file_path, "w") do |f|
      f.write(key.to_pem)
    end
  end

  task create_ca: :environment do
    private_key_path = Rails.root.join("storage", "certificates", "ca_private.key")
    create_private_key(private_key_path) unless File.exist?(private_key_path)
    # private_key = File.read(file_path)

    # Create CA Certificate Signing Request
    cnf_path = Rails.root.join("config", "certificates", "ca_openssl.cnf")
    csr_path = Rails.root.join("storage", "certificates", "ca.csr")
    system("openssl req -config #{cnf_path.to_s} -new -key #{private_key_path.to_s} -nodes -out #{csr_path.to_s}")


    ca_cert_path = Rails.root.join("storage", "certificates", "ca_certificate.crt")
    system("openssl x509 -signkey #{private_key_path.to_s} -in #{csr_path.to_s} -req -days 365 -out #{ca_cert_path.to_s}")
  end

  task create_cert: :environment do
    private_key_path = Rails.root.join("storage", "certificates", "client_private.key")
    create_private_key(private_key_path) unless File.exist?(private_key_path)
    # private_key = File.read(file_path)

    # Create Certificate Signing Request
    cnf_path = Rails.root.join("config", "certificates", "client_openssl.cnf")
    csr_path = Rails.root.join("storage", "certificates", "client.csr")
    system("openssl req -config #{cnf_path.to_s} -new -key #{private_key_path.to_s} -nodes -out #{csr_path.to_s}")

    ca_cert_path = Rails.root.join("storage", "certificates", "ca_certificate.crt")
    ca_private_key_path = Rails.root.join("storage", "certificates", "ca_private.key")
    cert_path = Rails.root.join("storage", "certificates", "client_signed_certificate.crt")
    system("openssl x509 -req -days 360 -extfile #{cnf_path.to_s} -extensions cert_ext -in #{csr_path.to_s} -CAcreateserial -CA #{ca_cert_path.to_s} -CAkey #{ca_private_key_path} -out #{cert_path.to_s}")
  end

  task register_tpp: :environment do
    # SaltEdge:RegisterTpp
  end

  task setup: :environment do
    Rake::Task['cert:create_ca'].invoke
    Rake::Task['cert:create_cert'].invoke
  end
end
