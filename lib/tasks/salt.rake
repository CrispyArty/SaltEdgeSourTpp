require "openssl"

namespace :salt do
  def create_private_key(file_path)
    key = OpenSSL::PKey::RSA.new(2048)

    FileUtils.mkdir_p(File.dirname(file_path))

    File.open(file_path, "w") do |f|
      f.write(key.to_pem)
    end
  end

  task create_ca: :environment do
    ca_cert_path = Rails.root.join("storage", "certificates", "ca_certificate.crt")

    if File.exist?(ca_cert_path)
      puts "CA Certificate already exists"

      next
    end

    private_key_path = Rails.root.join("storage", "certificates", "ca_private.key")
    create_private_key(private_key_path) unless File.exist?(private_key_path)
    # private_key = File.read(file_path)

    # Create CA Certificate Signing Request
    cnf_path = Rails.root.join("config", "certificates", "ca_openssl.cnf")
    csr_path = Rails.root.join("storage", "certificates", "ca.csr")
    system("openssl req -config #{cnf_path} -new -key #{private_key_path} -nodes -out #{csr_path}")

    # Create CA Certificate
    system("openssl x509 -signkey #{private_key_path} -in #{csr_path} -req -days 365 -out #{ca_cert_path}")
  end

  task create_cert: :environment do
    cert_path = Rails.root.join("storage", "certificates", "client_signed_certificate.crt")

    if File.exist?(cert_path)
      puts "Client Certificate already exists"

      next
    end

    private_key_path = Rails.root.join("storage", "certificates", "client_private.key")
    create_private_key(private_key_path) unless File.exist?(private_key_path)
    # private_key = File.read(file_path)

    # Create Certificate Signing Request
    cnf_path = Rails.root.join("config", "certificates", "client_openssl_md1.cnf")
    csr_path = Rails.root.join("storage", "certificates", "client.csr")
    system("openssl req -config #{cnf_path} -new -key #{private_key_path} -nodes -out #{csr_path}")

    ca_cert_path = Rails.root.join("storage", "certificates", "ca_certificate.crt")
    ca_private_key_path = Rails.root.join("storage", "certificates", "ca_private.key")

    # Create Client Certificate
    serial = SecureRandom.random_number(1 << 128)
    # serial = "1234567890987654321"
    system("openssl x509 -req -days 360 -extfile #{cnf_path} -extensions cert_ext -in #{csr_path} -set_serial #{serial} -CA #{ca_cert_path} -CAkey #{ca_private_key_path} -out #{cert_path}")
  end

  desc "Register tpp"
  task register_tpp: :environment do
    puts SaltEdge::RegisterTppService.call
  end

  desc "Adding certificate to tpp"
  task add_certificate: :environment do
    puts SaltEdge::AddCertificateService.call
  end

  desc "This task will create necessary certificate and will send it to tpp via api"
  task setup: :environment do
    Rake::Task["salt:create_ca"].invoke
    Rake::Task["salt:create_cert"].invoke
    Rake::Task["salt:add_certificate"].invoke
  end

  task verify_cert: :environment do
    test_cert = ::File.read(Rails.root.join("storage", "certificates", "client_signed_certificate.crt").to_s)

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
