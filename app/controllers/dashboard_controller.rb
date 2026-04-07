class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    # Request to get accounts happens too fast the first time after auth. Added small api request for fix
    SaltEdge::ConsentShowService.call(consent_id: current_user[:consent_id])

    @data = SaltEdge::AccountsService.call(consent_id: current_user[:consent_id])


    # json = '{"accounts":[{"resourceId":"480750","cashAccountType":"CACC","balances":[{"balanceType":"interimAvailable","balanceAmount":{"currency":"EUR","amount":"5166"},"referenceDate":"2019-10-25","creditLimitIncluded":true},{"balanceType":"interimBooked","balanceAmount":{"currency":"EUR","amount":"9141"},"lastChangeDateTime":"2019-10-25T15:30:35Z","creditLimitIncluded":true},{"balanceType":"closingBooked","balanceAmount":{"currency":"EUR","amount":"2323"},"referenceDate":"2019-10-25"},{"balanceType":"interimBooked","balanceAmount":{"currency":"EUR","amount":"3433"},"lastChangeDateTime":"2019-10-25T15:30:35Z"}],"iban":"LT60361869413939","bic":"XYIRYG48","ownerName":"owner_name","bankAccountIdentifier":"123412341234","name":"Current Account","status":"enabled","currency":"EUR","product":"Current Account","_links":{"transactions":{"href":"/artea_sandbox/api/berlingroup/v1/accounts/480750/transactions"}}},{"resourceId":"480751","cashAccountType":"CACC","balances":[{"balanceType":"interimAvailable","balanceAmount":{"currency":"EUR","amount":"2211"},"referenceDate":"2019-10-25","creditLimitIncluded":true},{"balanceType":"interimBooked","balanceAmount":{"currency":"EUR","amount":"3333"},"lastChangeDateTime":"2019-10-25T15:30:35Z"},{"balanceType":"closingBooked","balanceAmount":{"currency":"EUR","amount":"4434"},"referenceDate":"2019-10-25"},{"balanceType":"interimBooked","balanceAmount":{"currency":"EUR","amount":"2319"},"lastChangeDateTime":"2019-10-25T15:30:35Z"}],"iban":"LT58123628344087","bic":"FXSCEL69","ownerName":"owner_name","bankAccountIdentifier":"123412341234","name":"Aggregation Account","status":"enabled","currency":"EUR","product":"Current Account","_links":{"transactions":{"href":"/artea_sandbox/api/berlingroup/v1/accounts/480751/transactions"}}}]}'
    #
    #
    # @data = JSON.parse(json).with_indifferent_access
  end
end
