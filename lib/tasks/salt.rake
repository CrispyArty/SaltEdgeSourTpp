require 'openssl'

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
      puts 'CA Certificate already exists'

      next
    end

    private_key_path = Rails.root.join("storage", "certificates", "ca_private.key")
    create_private_key(private_key_path) unless File.exist?(private_key_path)
    # private_key = File.read(file_path)

    # Create CA Certificate Signing Request
    cnf_path = Rails.root.join("config", "certificates", "ca_openssl.cnf")
    csr_path = Rails.root.join("storage", "certificates", "ca.csr")
    system("openssl req -config #{cnf_path.to_s} -new -key #{private_key_path.to_s} -nodes -out #{csr_path.to_s}")

    # Create CA Certificate
    system("openssl x509 -signkey #{private_key_path.to_s} -in #{csr_path.to_s} -req -days 365 -out #{ca_cert_path.to_s}")
  end

  task create_cert: :environment do
    cert_path = Rails.root.join("storage", "certificates", "client_signed_certificate.crt")

    if File.exist?(cert_path)
      puts 'Client Certificate already exists'

      next
    end

    private_key_path = Rails.root.join("storage", "certificates", "client_private.key")
    create_private_key(private_key_path) unless File.exist?(private_key_path)
    # private_key = File.read(file_path)

    # Create Certificate Signing Request
    cnf_path = Rails.root.join("config", "certificates", "client_openssl.cnf")
    csr_path = Rails.root.join("storage", "certificates", "client.csr")
    system("openssl req -config #{cnf_path.to_s} -new -key #{private_key_path.to_s} -nodes -out #{csr_path.to_s}")

    ca_cert_path = Rails.root.join("storage", "certificates", "ca_certificate.crt")
    ca_private_key_path = Rails.root.join("storage", "certificates", "ca_private.key")

    # Create Client Certificate
    system("openssl x509 -req -days 360 -extfile #{cnf_path.to_s} -extensions cert_ext -in #{csr_path.to_s} -CAcreateserial -CA #{ca_cert_path.to_s} -CAkey #{ca_private_key_path} -out #{cert_path.to_s}")
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
    Rake::Task['salt:create_ca'].invoke
    Rake::Task['salt:create_cert'].invoke
    Rake::Task['salt:add_certificate'].invoke
  end

  # task verify_cert: :environment do
  #   test_cert = ::File.read(Rails.root.join("storage", "certificates", "client_signed_certificate.crt").to_s)
  #
  #   response = Excon.post(
  #     'https://priora.saltedge.com/api/tpp_verifiers/v2/certificates',
  #     headers: {
  #       "App-Id" => app_id,
  #       "App-Secret" => secret_id
  #     },
  #     body: "{ data: { certificate: #{test_cert} } }"
  #   )
  #
  #
  #   p '--response', response, response.body
  # end
end
