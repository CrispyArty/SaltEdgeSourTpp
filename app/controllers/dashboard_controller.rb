class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @data = SaltEdge::BG::AccountsEndpoint.call(consent_id: current_user[:consent_id])
  end
end
