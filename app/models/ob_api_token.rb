class OBApiToken < ApplicationRecord
  EXPIRY_LEEWAY = 30.seconds

  belongs_to :ob_consent

  validates :access_token, :id_token, :refresh_token, presence: true

  def expired?(leeway: EXPIRY_LEEWAY)
    expired_at.nil? || expired_at <= leeway.from_now
  end
end
