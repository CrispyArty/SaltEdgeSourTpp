# Test Tpp via Salt Edge Rails 8 Application
This app lets users view their banking account through our interface

## Video showcase
[<img src="https://img.youtube.com/vi/BHb5KkV5sM8/hqdefault.jpg" width="600" height="300"
/>](https://www.youtube.com/embed/BHb5KkV5sM8)

## Requirements
This app currently requires:

* **Rails 8.1**
* **Ruby ruby-3.4.4  or newer**
* **openssl** - System binary required for certificate generation via shell execution

## Setup
To run this app you need to run rake task that will set up necessary files.
```bash
> rails salt:setup
```
This command will create keys, Fake CA, Client Certificate and will send it to `/api/berlingroup/v1/tpp/certificates` to add to TPP. \
TPP client already exists, this command will only add new certificate to existing TPP

### Key Features of this setup:
* **No Database**: Runs entirely without a database connection (ActiveRecord omitted/bypassed).

## Tests
You can run tests via Rspec
```bash
> rspec
```
Tests use VCR cassettes and webmock so you don't have to worry about real http requests in tests. 

## Services

You can extend api with the help of [client_service.rb](app/services/salt_edge/client_service.rb)

Use case
```Ruby
client = ClientFactory.with_provider # for api calls with /:provider, default as artea_sandbox

client.get(
  'accounts', 
  headers: { 'Consent-Id' => consent_id }, 
  data: { withBalance: true }
)
```

## Diagram
<img width="1061" height="1111" alt="TppSaltEdge2 drawio" src="https://github.com/user-attachments/assets/90915c31-b12f-4fe2-9be4-c4a5b5a69462" />



## Docs inconsistencies and remarks

### Certificate creation and validation

- When creating certificate from `client_openssl.cnf` example, you need to be aware that UK is not valid ISO code for country. \
    Additionally, you can't use MD as a country code, because your certificate will be refused due to being invalid. \
    Example of invalid `.cnf` with MD code
    ```
    [ dn ]
    CN = Fake Sour Point TPP
    O = Fake Sour Point TPP
    C = MD
    ST = Fake Street
    organizationIdentifier = PSDMD-TEST-1337-207542
    ```
    If it wasn't an error on my part, it will be useful to mention this caveat in docs. 


- It is mentioned in the documentation that there is a certificate validation method:
  https://priora.saltedge.com/docs/tpp_verifier#certificates-verify-v2 \

  However, to use this API you need the TppVerifierClient app_id and app_secret. To obtain those credentials, a valid certificate is required to register a TPP client in the first place. \

  *Side note*: After I had registered a TPP client, I found its `app_id`, `app_secret` in dashboard, tried to use it with this api and received error
  ```
  {"error_class":"TppVerifierClientNotFound","error_message":"TppVerifierClient with App-Id: '12bba2a7-b5bc-43df-b214-f2bd8573b3e4' was not found.","meta":{"time":"2026-04-07T21:58:37Z","version":"V2"}}
  ```
### Error on getting transactions older than a year
If **dateTo** is older than a year from now, there is a weird error.

Current date: `2026-04-07`

---

#### Request with dateFrom `2025-03-15` and dateTo `2025-04-15` (less than a year from now)

```
/v1/accounts/480753/transactions?bookingStatus=both&dateFrom=2025-03-15&dateTo=2025-04-15
```
Response 200
```ruby
{"account" => {"bic" => "GMZAAG38", "iban" => "LT88196778668852", "currency" => "EUR", "bank_account_identifier" => "123412341234"},
 "transactions" => {"pending" => [], "booked" => [], "_links" => {"account" => {"href" => "/artea_sandbox/api/berlingroup/v1/accounts/480753"}}},
 "_links" => {"account" => {"href" => "/artea_sandbox/api/berlingroup/v1/accounts/480753"}}}
```
---

#### Request with dateFrom `2025-03-06` and dateTo `2025-04-06` (more than a year from now)

```
v1/accounts/480753/transactions?bookingStatus=both&dateFrom=2025-03-06&dateTo=2025-04-06
```

Response 400
```ruby
{"tppMessages" => [{"category" => "ERROR", "code" => "FORMAT_ERROR", "text" => "dateFrom cannot be greater than dateTo"}]}
```
"dateFrom cannot be greater than dateTo" \
Error is weird because **dateFrom** `2025-03-06` is less than **dateTo** `2025-04-06`


### Consent creation
There is a params in consent creation api method - `frequencyPerDay`. \
I thought that this parameter will limit my api calls with this consent, but there seems to be no limit, certainly not 4 per day.

It is not necessarily an inconsistency in doc. Just a thing that I have noticed


