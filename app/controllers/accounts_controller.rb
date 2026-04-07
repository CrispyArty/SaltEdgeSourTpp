class AccountsController < ApplicationController
  before_action :authenticate_user!

  def transactions
    @offset = params[:offset] ? params[:offset].to_i : 0
    @limit = params[:limit] ? params[:limit].to_i : 50

    @offset = 0 if @offset < 0

    data = SaltEdge::AccountTransactionsService.call(
      account_id: params[:id],
      consent_id: current_user[:consent_id],
      paginated: true,
      limit: @limit,
      offset: @offset
    )

    @pending = data[:transactions][:pending]
    @booked = data[:transactions][:booked]
    @next_page_params = data[:next_page_params]
  end
end
