class OBConsent < ApplicationRecord
  enum :status, { pending: 0, awaiting_auth: 1, valid: 2, rejected: 3, revoked: 4 }, prefix: true

  has_one :ob_api_token, dependent: :destroy

  validates :external_id, presence: true

  API_STATUSES = {
    "Pending" => :pending,
    "AwaitingAuthorisation" => :awaiting_auth,
    "Authorised" => :valid,
    "Rejected" => :rejected,
    "Revoked" => :revoked
  }.freeze

  def self.create_from_api!(response)
    create!(
      external_id: response.external_id,
      status: API_STATUSES.fetch(response.status),
      permissions: response.permissions,
      expired_at: response.expired_at
    )
  end

  def api_client
    SaltEdge::OB::ClientFactory.authorized(token_provider: OBApiTokenAuthAdapter.new(ob_api_token))
  end
end
