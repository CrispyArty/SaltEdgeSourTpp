require "openssl"

# Helpers for the :salt tasks below. Defined in a module rather than directly
# inside `namespace :salt do` — constants and `def`s inside a block leak into
# Object rather than scoping to the block.
module SaltCerts
  TYPE_QSEAL = "qseal".freeze
  TYPE_OBSEAL = "obseal".freeze

  module_function

  def create_private_key(file_path)
    key = OpenSSL::PKey::RSA.new(2048)

    FileUtils.mkdir_p(File.dirname(file_path))

    File.open(file_path, "w") do |f|
      f.write(key.to_pem)
    end
  end

  def create_cert_by_type(type = TYPE_QSEAL)
    cert_path = Rails.root.join("storage", "certificates", "cert_#{type}.pem")

    if File.exist?(cert_path)
      puts "Client Certificate already exists"

      return
    end

    private_key_path = Rails.root.join("storage", "certificates", "cert_#{type}.key")
    create_private_key(private_key_path) unless File.exist?(private_key_path)

    # Create Certificate Signing Request
    cnf_path = Rails.root.join("config/certificates/client_openssl.cnf")
    csr_path = Rails.root.join("storage/certificates/client.csr")
    system("openssl req -config #{cnf_path} -new -key #{private_key_path} -nodes -out #{csr_path}")

    ca_cert_path = Rails.root.join("storage/certificates/ca_certificate.crt")
    ca_private_key_path = Rails.root.join("storage/certificates/ca_private.key")

    # Create Client Certificate
    serial = SecureRandom.random_number(1 << 128)
    system("openssl x509 -req -days 360 -extfile #{cnf_path} -extensions cert_ext " \
           "-in #{csr_path} -set_serial #{serial} -CA #{ca_cert_path} " \
           "-CAkey #{ca_private_key_path} -out #{cert_path}")
  end
end

namespace :salt do
  task create_ca: :environment do
    ca_cert_path = Rails.root.join("storage/certificates/ca_certificate.crt")

    if File.exist?(ca_cert_path)
      puts "CA Certificate already exists"

      next
    end

    private_key_path = Rails.root.join("storage/certificates/ca_private.key")
    SaltCerts.create_private_key(private_key_path) unless File.exist?(private_key_path)

    # Create CA Certificate Signing Request
    cnf_path = Rails.root.join("config/certificates/ca_openssl.cnf")
    csr_path = Rails.root.join("storage/certificates/ca.csr")
    system("openssl req -config #{cnf_path} -new -key #{private_key_path} -nodes -out #{csr_path}")

    # Create CA Certificate
    system("openssl x509 -signkey #{private_key_path} -in #{csr_path} -req -days 365 -out #{ca_cert_path}")
  end

  task create_cert_ob: :environment do
    SaltCerts.create_cert_by_type(SaltCerts::TYPE_OBSEAL)
  end

  task create_cert_bg: :environment do
    SaltCerts.create_cert_by_type(SaltCerts::TYPE_QSEAL)
  end

  desc "Register tpp"
  task register_tpp: :environment do
    # TODO: OB register instead of BG
    # puts SaltEdge::BG::RegisterTppEndpoint.call
  end

  desc "Adding certificate to tpp"
  task add_certificate: :environment do
    puts SaltEdge::BG::AddCertificateEndpoint.call
    # puts SaltEdge::OB::AddCertificateEndpoint.call
  end

  desc "This task will create necessary certificate and will send it to tpp via api"
  task setup: :environment do
    Rake::Task["salt:create_ca"].invoke
    Rake::Task["salt:create_cert_bg"].invoke
    Rake::Task["salt:create_cert_ob"].invoke
    Rake::Task["salt:add_certificate"].invoke
  end

  task verify_cert: :environment do
    test_cert = ::File.read(Rails.root.join("storage/certificates/client_signed_certificate.crt").to_s)

    response = Excon.post(
      "https://priora.saltedge.com/api/tpp_verifiers/v2/certificates",
      headers: {
        "App-Id" => app_id,
        "App-Secret" => secret_id
      },
      body: "{ data: { certificate: #{test_cert} } }"
    )

    p "--response", response, response.body
  end
end
