# frozen_string_literal: true

describe ::SaltEdge::AccountTransactionsService do
  context "without paginator", vcr: { cassette_name: 'salt_edge/accounts/transactions/success' } do
    it 'returns both types of transactions' do
      result = described_class.call(consent_id: '385730', account_id: '480753')

      expect(result).to include(:account, :transactions)
      expect(result[:transactions]).to include(:pending, :booked)
      expect(result[:transactions][:pending]).to be_an_instance_of(Array)
      expect(result[:transactions][:booked]).to be_an_instance_of(Array)
      expect(result[:next_page_params]).to be_nil
    end
  end

  context "with paginator at first page", vcr: { cassette_name: 'salt_edge/accounts/transactions/success_with_pagination' } do
    it 'returns list of transactions with next page link' do
      result = described_class.call(consent_id: '385730', account_id: '480753', paginated: true)

      expect(result).to include(:account, :transactions)
      expect(result[:transactions]).to include(:pending, :booked)
      expect(result[:transactions][:pending]).to be_an_instance_of(Array)
      expect(result[:transactions][:booked]).to be_an_instance_of(Array)
      expect(result[:next_page_params]).to include(:offset, :limit)
      expect(result[:next_page_params][:offset]).to be_a(Integer)
    end
  end

  context "with paginator at last page", vcr: { cassette_name: 'salt_edge/accounts/transactions/success_with_pagination_last_page' } do
    it 'returns list of transactions without next page link' do
      result = described_class.call(consent_id: '385730', account_id: '480753', paginated: true, offset: 50, limit: 50)

      expect(result).to include(:account, :transactions)
      expect(result[:transactions]).to include(:pending, :booked)
      expect(result[:transactions][:pending]).to be_an_instance_of(Array)
      expect(result[:transactions][:booked]).to be_an_instance_of(Array)
      expect(result[:next_page_params]).to be_nil
    end
  end
end