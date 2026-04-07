# Test Tpp via Salt Edge Rails 8 Application
This app lets users view their banking account through our interface


## Requirements
This app currently requires:

* **Rails 8.1**
* **Ruby ruby-3.4.4  or newer**
* openssl

## Setup
To run this app you need to run rake task that will set up necessary files.
```
> rails salt:setup
```
This command will create keys, Fake CA, Client Certificate and will send it to `/api/berlingroup/v1/tpp/certificates` for validation. \
TPP client already exists, this command will only add new certificate to existing TPP

### Key Features of this setup:
* **No Database**: Runs entirely without a database connection (ActiveRecord omitted/bypassed).
---


