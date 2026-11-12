namespace :salt_ob do
  task auth_url: :environment do
    # Flow:
    # 1. Create client token
    # 2. Create consent
    # 3. Build link

    # client_token = SaltEdge::OB::TokenClientCredentialsEndpoint.call(
    #   provider: SaltEdge::Provider.new(code: provider)
    # )
    provider = SaltEdge::Provider.new(code: "yeepay_uk_preprod")
    # Note: before its own request, makes POST /api/oidc/:provider_code/token request
    # via TokenClientCredentialsEndpoint
    consent_response = SaltEdge::OB::ConsentCreateEndpoint.call(
      provider:
    )
    consent = OBConsent.build_from_api(consent_response)
    consent.state = SecureRandom.hex(16)
    consent.save!

    auth_link = SaltEdge::OB::BuildAuthorizeLink.call(
      consent_id: consent.external_id,
      auth_url: authorization_endpoint,
      state: consent.state,
      provider:,
    )

    p "OBConsent#external_id: #{consent.external_id}"
    p "OBConsent#id: #{consent.id}"
    p auth_link
  end

  task token_by_code: :environment do
    # first token exchange
    print "Enter consent_id: "
    consent_id = STDIN.gets.chomp

    print "Enter code: "
    code = STDIN.gets.chomp

    token = SaltEdge::OB::TokenAuthorizationCodeEndpoint.call(code:)

    OBApiToken.create!(token.attributes.merge(ob_consent_id: consent_id.to_i))

    p token
  end

  task ais_fetch: :environment do
    print "Enter consent_id: "
    consent_id = STDIN.gets.chomp

    accounts = SaltEdge::OB::AccountsEndpoint.call(client: OBConsent.find(consent_id.to_i).api_client)

    p accounts
  end
end
