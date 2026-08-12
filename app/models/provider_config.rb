class ProviderConfig < ApplicationRecord
  validates :code, presence: true

  def fetch_update!
    update!(SaltEdge::ProviderWellKnownEndpoint.call(provider_code: code))
  end
end
