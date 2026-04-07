# frozen_string_literal: true

describe ::SaltEdge::AccountsService do
  context "with existing accounts", vcr: { cassette_name: 'salt_edge/accounts/success_with_balances' } do
    it 'returns accounts with balances' do
      result = described_class.call(consent_id: '385730')

      expect(result).to include(:accounts)
      expect(result[:accounts]).to all(include(:resourceId, :bankAccountIdentifier, :currency, :name))
      expect(result[:accounts]).to all(include(:balances))
    end
  end
end