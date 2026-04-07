# frozen_string_literal: true

describe ::SaltEdge::ConsentShowService do
  context "with expired consent", vcr: { cassette_name: 'salt_edge/consent_show/rejected_no_redirect_link' } do
    it 'returns rejected consentStatus and no link' do
      result = described_class.call(consent_id: '385716')

      expect(result).to include(:consent_status)
      expect(result[:consent_status]).to eq('rejected')
      expect(result[:sca_redirect_link]).to be_nil
    end
  end

  context "with accepted consent", vcr: { cassette_name: 'salt_edge/consent_show/accepted_with_redirect_link' } do
    it 'returns accepted consentStatus and redirect link' do
      result = described_class.call(consent_id: '385719')

      expect(result).to include(:consent_status)
      expect(result[:consent_status]).to eq('received')
      expect(result[:sca_redirect_link]).to be_a(String)
      expect { URI.parse(result[:sca_redirect_link]) }.not_to raise_error
    end
  end
end