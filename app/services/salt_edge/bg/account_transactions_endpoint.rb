# frozen_string_literal: true

module SaltEdge
  module BG
    AccountTransactionsEndpoint = ::Data.define(:account_id, :consent_id, :paginated, :limit, :offset, :client) do
      extend Callable

      def initialize(
        account_id:,
        consent_id:,
        paginated: false,
        limit: 50,
        offset: 0,
        client: ClientFactory.with_provider
      ) = super

      def call
        data = client.get(
          "accounts/#{account_id}/transactions",
          headers: { "Consent-Id" => consent_id },
          query: {
            paginated: paginated ? 1 : nil,
            limit: paginated ? limit : nil,
            offset: paginated ? offset : nil,
            dateFrom: 90.days.ago.utc.strftime("%Y-%m-%d"), # "2025-09-11"
            dateTo: Time.now.utc.strftime("%Y-%m-%d"), # "2026-04-01"
            bookingStatus: "both"
          }.compact
        )

        data = data.with_indifferent_access

        if paginated && data.dig("_links", "next", "href")
          data = data.merge(next_page_params: extract_page_params(data.dig("_links", "next", "href")))
        end

        data
      end

      private

      def extract_page_params(url)
        uri = URI.parse(url)
        query = Rack::Utils.parse_nested_query(uri.query)

        {
          offset: query["offset"].to_i,
          limit: query["limit"].to_i
        }
      end
    end
  end
end
