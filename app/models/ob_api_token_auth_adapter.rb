class OBApiTokenAuthAdapter
  def initialize(record) = @record = record

  delegate :expired?, :access_token, to: :@record

  def refresh!
    @record.update!(
      SaltEdge::OB::TokenRefreshEndpoint.call(refresh_token: @record.refresh_token).attributes.compact
    )
  end
end
