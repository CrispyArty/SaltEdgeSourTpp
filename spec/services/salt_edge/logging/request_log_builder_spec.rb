# frozen_string_literal: true

describe ::SaltEdge::Logging::RequestLogBuilder do
  let(:headers) { { "Consent-Id" => "abc-123" } }
  let(:body)    { nil }
  let(:error)   { nil }
  let(:started) { 1_000_000.0 }

  describe "#build" do
    context "with a successful response" do
      let(:response) do
        Struct.new(:status, :headers, :body).new(
          200,
          { "Content-Type" => "application/json" },
          '{"accounts":[]}'
        )
      end

      it "shapes the payload with parsed JSON body and all fields" do
        payload = described_class.new(
          method: :get,
          url: "https://example.test/accounts",
          started_at: started,
          headers: headers,
          body: body,
          response: response,
          error: error,
          duration_ms: 12.34
        ).build

        expect(payload).to include(
          method: "GET",
          url: "https://example.test/accounts",
          status: 200,
          duration_ms: 12.34,
          request_headers: headers,
          request_body: nil,
          response_headers: { "Content-Type" => "application/json" },
          error_class: nil,
          error_message: nil
        )
        expect(payload[:response_body]).to eq({ "accounts" => [] })
      end
    end

    context "with a non-JSON response body" do
      let(:response) do
        Struct.new(:status, :headers, :body).new(204, {}, "")
      end

      it "falls back to the raw body string" do
        payload = described_class.new(
          method: :post,
          url: "https://example.test/x",
          started_at: started,
          headers: headers,
          body: '{"a":1}',
          response: response,
          error: error,
          duration_ms: 5.0
        ).build

        expect(payload[:request_body]).to eq({ "a" => 1 })
        expect(payload[:response_body]).to be_nil
      end
    end

    context "with an error and no response" do
      let(:error) { StandardError.new("boom") }

      it "records the error class and message and leaves response fields nil" do
        payload = described_class.new(
          method: :get,
          url: "https://example.test/x",
          started_at: started,
          headers: headers,
          body: body,
          response: nil,
          error: error,
          duration_ms: 1.0
        ).build

        expect(payload[:status]).to be_nil
        expect(payload[:response_headers]).to be_nil
        expect(payload[:response_body]).to be_nil
        expect(payload[:error_class]).to eq("StandardError")
        expect(payload[:error_message]).to eq("boom")
      end
    end

    context "with a request body that is not JSON" do
      let(:response) do
        Struct.new(:status, :headers, :body).new(200, {}, "{}")
      end

      it "returns nil for request_body when it cannot be parsed" do
        payload = described_class.new(
          method: :post,
          url: "https://example.test/x",
          started_at: started,
          headers: headers,
          body: "not-json",
          response: response,
          error: error,
          duration_ms: 1.0
        ).build

        expect(payload[:request_body]).to be_nil
      end
    end
  end
end
