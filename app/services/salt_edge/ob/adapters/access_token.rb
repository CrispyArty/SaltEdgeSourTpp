# frozen_string_literal: true

module SaltEdge
  module OB
    module Adapters
      AccessToken = ::Data.define(:access_token, :refresh_token, :id_token, :scope) do
        def initialize(access_token:, refresh_token:, id_token: nil, scope: nil)
          @payload = JWT.decode(id_token, nil, false).first if id_token.present?
          super
        end

        def attributes
          to_h.merge(issued_at:, expired_at:)
        end

        def expired_at
          Time.at(@payload["exp"]).utc if @payload.present?
        end

        def issued_at
          Time.at(@payload["iat"]).utc if @payload.present?
        end
      end
    end
  end
end
