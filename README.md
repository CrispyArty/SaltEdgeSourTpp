# Test Tpp via Salt Edge Rails 8 Application
This app lets users view their banking account through our interface

## Video showcase
[<img src="https://img.youtube.com/vi/BHb5KkV5sM8/hqdefault.jpg" width="600" height="300"
/>](https://www.youtube.com/embed/BHb5KkV5sM8)

## Requirements
This app currently requires:

* **Rails 8.1**
* **Ruby ruby-3.4.4  or newer**
* openssl

## Setup
To run this app you need to run rake task that will set up necessary files.
```bash
> rails salt:setup
```
This command will create keys, Fake CA, Client Certificate and will send it to `/api/berlingroup/v1/tpp/certificates` for validation. \
TPP client already exists, this command will only add new certificate to existing TPP

### Key Features of this setup:
* **No Database**: Runs entirely without a database connection (ActiveRecord omitted/bypassed).

## Tests
You can run tests via
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

