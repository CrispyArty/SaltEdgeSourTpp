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
    consent.provider_code = provider.code
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
    consent = Consent.find!(consent_id)

    print "Enter code: "
    code = STDIN.gets.chomp

    token = SaltEdge::OB::TokenAuthorizationCodeEndpoint.call(code:, provider: consent.provider_code)

    OBApiToken.create!(token.attributes.merge(ob_consent_id: consent_id.to_i))

    p token
  end

  task ais_fetch: :environment do
    print "Enter consent_id: "
    consent_id = STDIN.gets.chomp

    accounts = SaltEdge::OB::AccountsEndpoint.call(client: OBConsent.find(consent_id.to_i).api_client)

    p accounts
  end

  # Nomo international payment consent. Every field is valid for Nomo except LocalInstrument:
  # the group enables only UK.Nomo.CurrencyCloud, so Priora must answer 400 UnsupportedLocalInstrument.
  # Usage: bin/rails salt_ob:pis_create PROVIDER=nomo_sandbox LOCAL_INSTRUMENT=UK.OBIE.SEPACreditTransfer
  task pis_create: :environment do
    provider = SaltEdge::Provider.new(code: ENV.fetch("PROVIDER", "nomo_sandbox"))
    local_instrument = ENV.fetch("LOCAL_INSTRUMENT", "UK.OBIE.SEPACreditTransfer")

    body = {
      Data: {
        Initiation: {
          InstructionIdentification: "SOUR#{SecureRandom.hex(4)}",
          EndToEndIdentification: "SOUR.E2E.#{SecureRandom.hex(4)}",
          LocalInstrument: local_instrument,
          CurrencyOfTransfer: "EUR",
          InstructedAmount: { Amount: "10.00", Currency: "GBP" },
          DebtorAccount: {
            SchemeName: "UK.OBIE.IBAN",
            Identification: "GB33BUKB20201555555555",
            Name: "Debtor Name"
          },
          CreditorAgent: {
            SchemeName: "UK.OBIE.BICFI",
            Identification: "AAAADEBBXXX",
            Name: "Creditor Bank",
            PostalAddress: { Country: "DE" }
          },
          CreditorAccount: {
            SchemeName: "UK.OBIE.IBAN",
            Identification: "DE89370400440532013000",
            Name: "Creditor Name"
          },
          Creditor: {
            Name: "Creditor Name",
            PostalAddress: {
              AddressLine: "Unter den Linden 1",
              PostCode: "10117",
              CountrySubDivision: "BE",
              TownName: "Berlin",
              Country: "DE"
            }
          },
          RemittanceInformation: {
            Reference: "SourTpp test",
            Unstructured: "Nomo LocalInstrument check"
          },
          SupplementaryData: {
            FundsSource: "salary",
            TransferPurpose: "pay_bills",
            AdditionalCreditorDetails: {
              CreditorType: "individual",
              Name: { FirstName: "Creditor", LastName: "Name" }
            }
          }
        }
      },
      Risk: {}
    }

    consent = SaltEdge::OB::PaymentConsentCreateEndpoint.call(provider:, body:)
    p consent
  rescue ApiClient::Errors::ResponseError => e
    p status: e.status, code: e.code, message: e.message
    p e.body
  end
end
