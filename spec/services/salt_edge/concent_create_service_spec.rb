# frozen_string_literal: true

describe ::SaltEdge::ConsentCreateService do
  context "with accepted consent status", vcr: { cassette_name: 'salt_edge/consent_create/accepted' } do
    it 'returns consent_id' do
      result = described_class.call(redirect_url: 'http://localhost:3000/redirect_link')

      expect(result).to include(:consent_id)
      expect(result[:consent_id]).to be_a(String)
    end
  end
end